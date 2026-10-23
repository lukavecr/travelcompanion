import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/app_settings.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../vault/vault_types.dart';
import 'trip_reminders.dart';
import '../../l10n/tr.dart';

/// Plánuje upozornění na položky dne. Čas položky se bere jako místní čas
/// v pásmu, ve kterém je telefon při plánování. Při každém otevření aplikace
/// se vše naplánuje znovu, takže po přeletu do jiného pásma stačí aplikaci
/// jednou otevřít.
class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;
  static bool _askedExact = false;
  static Future<void> _last = Future.value();

  static Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // o povolení se aplikace zeptá až při prvním upozornění (ensurePermissions)
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Zeptá se na povolení oznámení a (jednou za spuštění) na přesné časy.
  static Future<void> ensurePermissions() async {
    try {
      await init();
      await _android?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      final exact = await _android?.canScheduleExactNotifications() ?? false;
      if (!exact && !_askedExact) {
        _askedExact = true;
        await _android?.requestExactAlarmsPermission();
      }
    } catch (_) {}
  }

  static List<CalendarEvent> _events = const [];
  static List<VaultItem> _vault = const [];
  static List<TripReminder> _trip = const [];

  /// Automatická upozornění na cestu (check-in, odlet, odjezd z ubytování).
  static Future<void> syncTrip(List<TripReminder> items) {
    _trip = items;
    return _schedule();
  }

  /// Zruší všechna naplánovaná upozornění a naplánuje znovu ta budoucí.
  static Future<void> sync(List<CalendarEvent> events) {
    _events = events;
    return _schedule();
  }

  /// Konec platnosti pasu, víz, pojištění… (Vault). Text neobsahuje citlivé údaje,
  /// jen typ dokladu a datum – oznámení je vidět i na zamčeném telefonu.
  static Future<void> syncVault(List<VaultItem> items) {
    _vault = items;
    return _schedule();
  }

  /// Znovu naplánovat (např. po změně času upozornění v Nastavení).
  static Future<void> reschedule() => _schedule();

  static Future<void> _schedule() {
    final events = _events;
    final vault = _vault;
    final trip = _trip;
    _last = _last.then((_) => _run(events, vault, trip)).catchError((Object _) {});
    return _last;
  }

  static int _idFor(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }

  static Future<void> _run(
      List<CalendarEvent> events, List<VaultItem> vault, List<TripReminder> trip) async {
    await init();
    await _plugin.cancelAll();
    final now = DateTime.now();
    final exact = await _android?.canScheduleExactNotifications() ?? false;

    for (final e in events) {
      final start = e.startMinutes;
      final lead = e.remindMinutes;
      if (start == null || lead == null) continue;
      final fire =
          DateTime(e.date.year, e.date.month, e.date.day, 0, start - lead);
      if (!fire.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        id: _idFor(e.id),
        title: e.title,
        body: tr('Za {lead} · {time}', {'lead': fmtLead(lead), 'time': fmtTime(start)}),
        scheduledDate:
            tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, fire.millisecondsSinceEpoch),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            tr('Upozornění na plán'),
            channelDescription: tr('Upozornění před položkami plánu dne'),
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    final settings = AppSettings.instance;
    for (final r in settings.tripReminders ? trip : const <TripReminder>[]) {
      if (!r.fire.isAfter(now)) continue;
      await _plugin.zonedSchedule(
        id: _idFor(r.key),
        title: r.title,
        body: r.body,
        scheduledDate: tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, r.fire.millisecondsSinceEpoch),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_reminders',
            tr('Upozornění na cestu'),
            channelDescription: tr('Check-in, odjezd na letiště a odjezd z ubytování'),
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    for (final v in settings.expiryReminders ? vault : const <VaultItem>[]) {
      final exp = v.expiresAt;
      if (exp == null) continue;
      final t = vaultType(v.type);
      for (final days in t.remindDays) {
        final d = exp.subtract(Duration(days: days));
        final fire = DateTime(d.year, d.month, d.day, 0, settings.expiryReminderMinutes);
        if (!fire.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: _idFor('${v.id}#$days'),
          title: days == 0 ? tr('{label}: dnes končí platnost', {'label': t.label}) : tr('{label}: blíží se konec platnosti', {'label': t.label}),
          body: days == 0
              ? tr('Platnost končí dnes ({exp}). Detail najdeš ve Vaultu.', {'exp': fmtDate(exp)})
              : tr('Platnost končí {exp} ({days}). Detail najdeš ve Vaultu.', {'exp': fmtDate(exp), 'days': fmtDaysAhead(days)}),
          scheduledDate:
              tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, fire.millisecondsSinceEpoch),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'vault_expiry',
              tr('Konec platnosti dokladů'),
              channelDescription: tr('Pas, víza, pojištění a další doklady z Vaultu'),
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }
}
