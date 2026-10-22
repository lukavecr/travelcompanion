import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_handler/share_handler.dart';

import 'core/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_settings.dart';
import 'core/week_start_localizations.dart';
import 'features/lock/app_lock.dart';
import 'features/pro/pro_service.dart';
import 'features/vault/vault_repository.dart';
import 'core/theme.dart';
import 'data/database.dart';
import 'features/auth/auth_providers.dart';
import 'features/reminders/reminder_service.dart';
import 'features/sync/sync_service.dart';
import 'features/trips/trip_repository.dart';
import 'l10n/tr.dart';

class TravelApp extends ConsumerStatefulWidget {
  const TravelApp({super.key});

  @override
  ConsumerState<TravelApp> createState() => _TravelAppState();
}

class _TravelAppState extends ConsumerState<TravelApp>
    with WidgetsBindingObserver {
  StreamSubscription<SharedMedia>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initShare();
    // záloha: po přihlášení a při každém návratu do aplikace (jen Pro)
    ref.read(syncServiceProvider).start();
    ProService.instance.init();
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
    ref.listenManual<AsyncValue<List<VaultItem>>>(
      vaultExpiryProvider,
      (prev, next) {
        final list = next.value;
        if (list != null) ReminderService.syncVault(list);
      },
      fireImmediately: true,
    );
  }

  Future<void> _initShare() async {
    final handler = ShareHandlerPlatform.instance;
    final initial = await handler.getInitialSharedMedia();
    if (initial != null) _handle(initial);
    _sub = handler.sharedMediaStream.listen(_handle);
  }

  Future<void> _handle(SharedMedia media) async {
    final text = media.content?.trim();
    if (text == null || text.isEmpty) return;
    try {
      await ref.read(authStateProvider.future); // počkej na přihlášení
    } catch (_) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    ref.read(routerProvider).push('/share', extra: text);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncServiceProvider).syncNow();
    }
  }

  /// Změna nastavení: překreslit celou aplikaci (formáty data, měna…), stav obrazovek zůstává.
  void _onSettings() {
    if (!mounted) return;
    ReminderService.reschedule(); // texty upozornění v novém jazyce / nový čas
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
