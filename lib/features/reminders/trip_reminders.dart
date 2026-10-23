import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/tr.dart';

/// Jedno automatické upozornění na cestu (check-in, odjezd na letiště, odjezd z ubytování).
class TripReminder {
  const TripReminder(this.key, this.fire, this.title, this.body);
  final String key; // stálé id (kvůli přeplánování)
  final DateTime fire;
  final String title;
  final String body;
}

/// Lety z uložených palubních lístků (typ dokladu „flight“ s datem odletu).
final flightsForRemindersProvider = StreamProvider<List<(Ticket, Document)>>((ref) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.tickets).join([
    innerJoin(db.documents, db.documents.id.equalsExp(db.tickets.documentId)),
  ])
    ..where(db.tickets.deletedAt.isNull() &
        db.documents.deletedAt.isNull() &
        db.tickets.departAt.isNotNull() &
        db.documents.type.equals('flight'));
  return q.watch().map((rows) => [
        for (final r in rows) (r.readTable(db.tickets), r.readTable(db.documents)),
      ]);
});

/// Ubytování v plánu (položky s datem „do“).
final staysForRemindersProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.calendarEvents)
        ..where((e) => e.deletedAt.isNull() & e.endDate.isNotNull()))
      .watch();
});

/// Z letů a ubytování spočítá upozornění (jen budoucí se pak naplánují).
List<TripReminder> buildTripReminders(List<(Ticket, Document)> flights, List<CalendarEvent> stays) {
  final out = <TripReminder>[];
  for (final (t, d) in flights) {
    final dep = t.departAt!;
    final label = (t.number?.isNotEmpty ?? false) ? t.number!.toUpperCase() : d.title;
    final from = (t.fromPlace?.isNotEmpty ?? false) ? t.fromPlace!.toUpperCase() : null;
    final hasTime = dep.hour != 0 || dep.minute != 0;
    final when = hasTime ? '${fmtDate(dep)} ${fmtTime(dep.hour * 60 + dep.minute)}' : fmtDate(dep);
    // check-in: 24 h předem; když čas neznáme, den předem v 9:00
    out.add(TripReminder(
      'checkin#${t.id}',
      hasTime ? dep.subtract(const Duration(hours: 24)) : DateTime(dep.year, dep.month, dep.day - 1, 9),
      tr('✈ {flight}: online check-in', {'flight': label}),
      from == null
          ? tr('Odlet {when}. Check-in bývá otevřený 24 h předem.', {'when': when})
          : tr('Odlet {when} z {from}. Check-in bývá otevřený 24 h předem.', {'when': when, 'from': from}),
    ));
    if (hasTime) {
      out.add(TripReminder(
        'depart#${t.id}',
        dep.subtract(const Duration(hours: 3)),
        tr('✈ {flight} za 3 hodiny', {'flight': label}),
        from == null
            ? tr('Odlet v {time} – čas vyrazit na letiště.', {'time': fmtTime(dep.hour * 60 + dep.minute)})
            : tr('Odlet v {time} z {from} – čas vyrazit na letiště.',
                {'time': fmtTime(dep.hour * 60 + dep.minute), 'from': from}),
      ));
    }
  }
  for (final e in stays) {
    final end = e.endDate!;
    out.add(TripReminder(
      'checkout#${e.id}',
      DateTime(end.year, end.month, end.day, 8),
      tr('🏨 Dnes odjezd: {title}', {'title': e.title}),
      tr('Nezapomeň na check-out a doklady v trezoru pokoje.'),
    ));
  }
  return out;
}
