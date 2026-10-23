import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../onboarding/demo_trip.dart';
import '../../l10n/tr.dart';

const _androidName = 'PlanWidgetProvider';
const widgetDays = 14; // data dopředu – widget si po půlnoci sám vybere správné dny

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class WidgetPayload {
  const WidgetPayload(this.title, this.days, this.spend);
  final String title;
  final List<Map<String, Object>> days; // {d, label, items}
  final Map<String, String> spend; // datum → „1 234 CZK“
}

/// Připraví obsah widgetu: plán na [widgetDays] dní od [today] a útratu po dnech.
WidgetPayload buildWidgetPayload({
  required List<Trip> trips,
  required List<CalendarEvent> events,
  required List<Expense> expenses,
  required DateTime today,
}) {
  final t0 = dayOnly(today);
  final live = {
    for (final t in trips)
      if (t.deletedAt == null && t.notes != demoTripNote) t.id: t
  };

  // název: probíhající cesta, jinak nejbližší budoucí
  Trip? active;
  for (final t in live.values) {
    final s = t.startDate == null ? null : dayOnly(t.startDate!);
    final e = t.endDate == null ? null : dayOnly(t.endDate!);
    if (s != null && !s.isAfter(t0) && (e == null || !e.isBefore(t0))) active = t;
  }
  if (active == null) {
    final next = live.values.where((t) => t.startDate != null && dayOnly(t.startDate!).isAfter(t0)).toList()
      ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
    if (next.isNotEmpty) active = next.first;
  }

  final ev = events.where((e) => e.deletedAt == null && live.containsKey(e.tripId)).toList();
  final days = <Map<String, Object>>[];
  for (var i = 0; i < widgetDays; i++) {
    final d = t0.add(Duration(days: i));
    final todays = ev.where((e) => dayOnly(e.date) == d).toList()
      ..sort((a, b) {
        final am = a.startMinutes, bm = b.startMinutes;
        if (am != null && bm != null) return am.compareTo(bm);
        if (am != null) return 1;
        if (bm != null) return -1;
        return a.sortOrder.compareTo(b.sortOrder);
      });
    final items = <String>[
      for (final e in ev.where((e) => e.endDate != null && dayOnly(e.endDate!) == d))
        '🏨 ${tr('Odjezd: {d}', {'d': e.title})}',
      for (final e in todays)
        e.startMinutes != null ? '${fmtTime(e.startMinutes!)}  ${e.title}' : e.title,
    ];
    days.add({'d': _ymd(d), 'label': fmtDay(d), 'items': items});
  }

  // útrata po dnech v hlavní měně cesty
  final spend = <String, String>{};
  final sums = <String, Map<String, double>>{};
  for (final x in expenses) {
    if (x.deletedAt != null || !live.containsKey(x.tripId)) continue;
    final d = dayOnly(x.spentAt);
    if (d.isBefore(t0) || !d.isBefore(t0.add(const Duration(days: widgetDays)))) continue;
    final cur = x.amountMain != null ? live[x.tripId]!.mainCurrency : x.currency;
    final m = sums.putIfAbsent(_ymd(d), () => {});
    m[cur] = (m[cur] ?? 0) + (x.amountMain ?? x.amount);
  }
  sums.forEach((d, m) {
    spend[d] = m.entries.map((e) => '${fmtMoney(e.value)} ${e.key}').join(' + ');
  });

  return WidgetPayload(active?.name ?? 'Travel Companion', days, spend);
}

/// Uloží data pro widget a překreslí ho. Volá se po změně plánu/výdajů a při startu.
class HomeWidgetService {
  HomeWidgetService(this.db);
  final AppDatabase db;
  StreamSubscription<Set<TableUpdate>>? _sub;
  Timer? _debounce;

  void start() {
    unawaited(update());
    _sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.trips, db.calendarEvents, db.expenses]))
        .listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 2), update);
    });
  }

  void dispose() {
    _sub?.cancel();
    _debounce?.cancel();
  }

  Future<void> update() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final now = DateTime.now();
      final from = dayOnly(now);
      final p = buildWidgetPayload(
        trips: await db.select(db.trips).get(),
        events: await (db.select(db.calendarEvents)
              ..where((e) =>
                  e.deletedAt.isNull() &
                  (e.date.isBiggerOrEqualValue(from.subtract(const Duration(days: 60))))))
            .get(),
        expenses: await (db.select(db.expenses)
              ..where((e) => e.deletedAt.isNull() & e.spentAt.isBiggerOrEqualValue(from)))
            .get(),
        today: now,
      );
      await HomeWidget.saveWidgetData<String>('w_title', p.title);
      await HomeWidget.saveWidgetData<String>('w_days', jsonEncode(p.days));
      await HomeWidget.saveWidgetData<String>('w_spend', jsonEncode(p.spend));
      await HomeWidget.saveWidgetData<String>('w_today', tr('Dnes'));
      await HomeWidget.saveWidgetData<String>('w_tomorrow', tr('Zítra'));
      await HomeWidget.saveWidgetData<String>('w_empty', tr('Nic naplánováno'));
      await HomeWidget.saveWidgetData<String>('w_spent', tr('Dnes utraceno'));
      await HomeWidget.updateWidget(androidName: _androidName);
      // o půlnoci překreslit (dnešek se posune), na dva týdny dopředu
      await HomeWidget.scheduleWidgetUpdates(
        [for (var i = 1; i <= widgetDays; i++) from.add(Duration(days: i, minutes: 1))],
        androidName: _androidName,
      );
    } catch (e) {
      debugPrint('widget: $e');
    }
  }
}
