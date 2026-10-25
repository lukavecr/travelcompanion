import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_handler/share_handler.dart';

import 'core/router.dart';
import 'features/ai_plan/ai_trip.dart';
import 'features/documents/email_parser.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_settings.dart';
import 'core/week_start_localizations.dart';
import 'features/lock/app_lock.dart';
import 'features/pro/pro_service.dart';
import 'features/reminders/trip_reminders.dart';
import 'features/vault/vault_repository.dart';
import 'core/theme.dart';
import 'data/database.dart';
import 'features/auth/auth_providers.dart';
import 'features/reminders/reminder_service.dart';
import 'features/sync/sync_service.dart';
import 'features/trips/trip_repository.dart';
import 'features/share/shared_trips.dart';
import 'features/tracks/tracker_service.dart';
import 'features/widget/home_widget_service.dart';
import 'l10n/tr.dart';

/// Zprávy (SnackBar) i mimo konkrétní obrazovku – např. po klepnutí na widget.
final rootScaffoldKey = GlobalKey<ScaffoldMessengerState>();

class TravelApp extends ConsumerStatefulWidget {
  const TravelApp({super.key});

  @override
  ConsumerState<TravelApp> createState() => _TravelAppState();
}

class _TravelAppState extends ConsumerState<TravelApp>
    with WidgetsBindingObserver {
  StreamSubscription<SharedMedia>? _sub;
  StreamSubscription<Uri?>? _widgetSub;
  late final HomeWidgetService _widget = HomeWidgetService(ref.read(databaseProvider));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShare();
    // záloha: po přihlášení a při každém návratu do aplikace (jen Pro)
    ref.read(syncServiceProvider).start();
    ProService.instance.init();
    _widget.start(); // widget na plochu: plán na 3 dny + dnešní útrata
    TrackerService.instance.init(ref.read(databaseProvider));
    _initWidgetClicks();
    SharedTrips.instance.start(ref.read(databaseProvider)); // společné cesty (i ve verzi zdarma)
    AppSettings.instance.addListener(_onSettings);
    var wasPro = false;
    ProService.instance.addListener(() {
      final isPro = ProService.instance.isPro;
      if (isPro && !wasPro) ref.read(syncServiceProvider).syncNow();
      wasPro = isPro;
    });
    ref.listenManual(
      authStateProvider,
      (prev, next) {
        if (next.value != null) ref.read(syncServiceProvider).syncNow();
      },
      fireImmediately: true,
    );
    // při startu a při každé změně položek znovu naplánuj upozornění
    ref.listenManual<AsyncValue<List<CalendarEvent>>>(
      reminderEventsProvider,
      (prev, next) {
        final list = next.value;
        if (list != null) ReminderService.sync(list);
      },
      fireImmediately: true,
    );
    // check-in, odjezd na letiště, odjezd z ubytování
    void tripReminders() {
      final f = ref.read(flightsForRemindersProvider).value;
      final s = ref.read(staysForRemindersProvider).value;
      if (f != null && s != null) ReminderService.syncTrip(buildTripReminders(f, s));
    }
    ref.listenManual(flightsForRemindersProvider, (_, _) => tripReminders(), fireImmediately: true);
    ref.listenManual(staysForRemindersProvider, (_, _) => tripReminders(), fireImmediately: true);
    ref.listenManual<AsyncValue<List<VaultItem>>>(
      vaultExpiryProvider,
      (prev, next) {
        final list = next.value;
        if (list != null) ReminderService.syncVault(list);
      },
      fireImmediately: true,
    );
  }

  /// Klepnutí na widget: travelcompanion://open = jen otevřít, travelcompanion://track = Start/Stop trasy.
  Future<void> _initWidgetClicks() async {
    _widgetSub = HomeWidget.widgetClicked.listen(_onWidget);
    _onWidget(await HomeWidget.initiallyLaunchedFromHomeWidget());
  }

  Future<void> _onWidget(Uri? uri) async {
    if (uri?.host == 'steps') return _enableSteps();
    if (uri?.host != 'track') return;
    await Future<void>.delayed(const Duration(milliseconds: 600)); // až je aplikace vykreslená
    if (!mounted) return;
    final t = TrackerService.instance;
    if (t.recording) {
      await t.stop();
    } else {
      final err = await t.start();
      if (err != null) {
        rootScaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(err)));
      }
    }
    ref.read(routerProvider).go('/map/tracks');
  }

  /// Dlaždice kroků na widgetu: když jsou vypnuté, požádá o oprávnění a zapne je.
  Future<void> _enableSteps() async {
    if (AppSettings.instance.widgetSteps) return;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!(await Permission.activityRecognition.request()).isGranted) {
      rootScaffoldKey.currentState?.showSnackBar(
          SnackBar(content: Text(tr('Bez oprávnění „Fyzická aktivita“ nejde kroky číst.'))));
      return;
    }
    await AppSettings.instance.setWidgetSteps(true);
    rootScaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(tr('Kroky na widgetu jsou zapnuté.'))));
  }

  Future<void> _initShare() async {
    final handler = ShareHandlerPlatform.instance;
    final initial = await handler.getInitialSharedMedia();
    if (initial != null) _handle(initial);
    _sub = handler.sharedMediaStream.listen(_handle);
  }

  Future<void> _handle(SharedMedia media) async {
    var text = media.content?.trim();
    String? fileName;
    // sdílený soubor (CSV / JSON od AI ze složky Stažené)
    if (text == null || text.isEmpty) {
      for (final a in media.attachments ?? const <SharedAttachment?>[]) {
        final path = a?.path;
        if (path == null) continue;
        try {
          final f = File(path);
          if (await f.length() > 2 * 1024 * 1024) continue;
          text = utf8.decode(await f.readAsBytes(), allowMalformed: true);
          fileName = path.split(RegExp(r'[\\/]')).last;
          break;
        } catch (_) {}
      }
    }
    if (text == null || text.isEmpty) return;
    try {
      await ref.read(authStateProvider.future); // počkej na přihlášení
    } catch (_) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    // plán z AI → nová cesta, text e-mailu s rezervací → doklad, jinak místo z Google Map
    final route = looksLikeAiTrip(text)
        ? '/trips/ai'
        : looksLikeBooking(text)
            ? '/docs/import'
            : '/share';
    ref.read(routerProvider).push(route, extra: route == '/trips/ai' ? (text, fileName) : text);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncServiceProvider).syncNow();
      _widget.update();
    }
  }

  /// Změna nastavení: překreslit celou aplikaci (formáty data, měna…), stav obrazovek zůstává.
  void _onSettings() {
    if (!mounted) return;
    ReminderService.reschedule(); // texty upozornění v novém jazyce / nový čas
    _widget.update();
    setState(() {});
    void mark(Element e) {
      e.markNeedsBuild();
      e.visitChildren(mark);
    }
    (context as Element).visitChildren(mark);
  }

  @override
  void dispose() {
    AppSettings.instance.removeListener(_onSettings);
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _widgetSub?.cancel();
    _widget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scaffoldMessengerKey: rootScaffoldKey,
      title: tr('Travel Companion AI'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: AppSettings.instance.themeMode,
      locale: Locale(AppSettings.instance.effectiveLanguage),
      supportedLocales: [for (final l in AppSettings.supportedLanguages) Locale(l)],
      localizationsDelegates: const [
        WeekStartMaterialDelegate(), // místo GlobalMaterialLocalizations – kvůli začátku týdne
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      // 12/24 h i ve výběru času (showTimePicker) podle nastavení
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: AppSettings.instance.use24h),
        child: AppLockGate(child: child ?? const SizedBox()),
      ),
    );
  }
}
