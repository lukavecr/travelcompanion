import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/format.dart';
import '../../data/database.dart';

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
      final exact = await _android?.canScheduleExactNotifications() ?? false;
      if (!exact && !_askedExact) {
        _askedExact = true;
        await _android?.requestExactAlarmsPermission();
      }
    } catch (_) {}
  }

  /// Zruší všechna naplánovaná upozornění a naplánuje znovu ta budoucí.
  static Future<void> sync(List<CalendarEvent> events) {
    _last = _last.then((_) => _run(events)).catchError((Object _) {});
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

  static Future<void> _run(List<CalendarEvent> events) async {
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
        body: 'Za ${fmtLead(lead)} · ${fmtTime(start)}',
        scheduledDate:
            tz.TZDateTime.fromMillisecondsSinceEpoch(tz.UTC, fire.millisecondsSinceEpoch),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Upozornění na plán',
            channelDescription: 'Upozornění před položkami plánu dne',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
