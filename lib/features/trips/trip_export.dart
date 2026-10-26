import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../../l10n/tr.dart';
import '../documents/doc_types.dart';

/// Data cesty pro export (plán, místa, doklady, výdaje).
class TripData {
  TripData(this.trip, this.events, this.places, this.docs, this.tickets, this.expenses);
  final Trip trip;
  final List<CalendarEvent> events;
  final Map<String, Place> places;
  final List<Document> docs;
  final Map<String, Ticket> tickets; // podle documentId
  final List<Expense> expenses;
}

Future<TripData> _load(AppDatabase db, String tripId) async {
  final trip = await (db.select(db.trips)..where((t) => t.id.equals(tripId))).getSingle();
  final events = await (db.select(db.calendarEvents)
        ..where((e) => e.tripId.equals(tripId) & e.deletedAt.isNull())
        ..orderBy([(e) => OrderingTerm.asc(e.date), (e) => OrderingTerm.asc(e.sortOrder)]))
      .get();
  final places = {
    for (final pl in await (db.select(db.places)
          ..where((x) => x.tripId.equals(tripId) & x.deletedAt.isNull()))
        .get())
      pl.id: pl,
  };
  final docs = await (db.select(db.documents)
        ..where((d) => d.tripId.equals(tripId) & d.deletedAt.isNull()))
      .get();
  final ids = docs.map((d) => d.id).toList();
  final tickets = {
    for (final t in await (db.select(db.tickets)
          ..where((t) => t.documentId.isIn(ids) & t.deletedAt.isNull()))
        .get())
      t.documentId: t,
  };
  final expenses = await (db.select(db.expenses)
        ..where((e) => e.tripId.equals(tripId) & e.deletedAt.isNull()))
      .get();
  return TripData(trip, events, places, docs, tickets, expenses);
}

String _safeName(String s) => s.replaceAll(RegExp(r'[^\w\- ]+', unicode: true), '').trim().replaceAll(' ', '-');

Future<File> _write(String name, List<int> bytes) async {
  final dir = Directory(p.join((await getTemporaryDirectory()).path, 'export'));
  if (!await dir.exists()) await dir.create(recursive: true);
  final f = File(p.join(dir.path, name));
  await f.writeAsBytes(bytes);
  return f;
}

// ---------------- kalendář (ICS) ----------------

String _icsEscape(String s) =>
    s.replaceAll('\\', '\\\\').replaceAll(';', '\\;').replaceAll(',', '\\,').replaceAll('\n', '\\n');

String _d8(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

String _dt(DateTime d) =>
    '${_d8(d)}T${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}00';

/// Řádky ICS delší než 75 znaků se lámou (RFC 5545).
String _fold(String line) {
  if (line.length <= 74) return line;
  final b = StringBuffer(line.substring(0, 74));
  for (var i = 74; i < line.length; i += 73) {
    b.write('\r\n ${line.substring(i, (i + 73).clamp(0, line.length))}');
  }
  return b.toString();
}

/// Plán cesty jako soubor kalendáře (.ics) – Google Kalendář, Outlook, Apple Kalendář.
String buildTripIcs(Trip trip, List<CalendarEvent> events, Map<String, Place> places) {
  final now = DateTime.now().toUtc();
  final stamp = '${_dt(now)}Z';
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//LR Tech CZ//Comes Viae//EN',
    'CALSCALE:GREGORIAN',
    'X-WR-CALNAME:${_icsEscape(trip.name)}',
  ];
  void event(String uid, List<String> body) =>
      lines..add('BEGIN:VEVENT')..add('UID:$uid@travelcompanion')..add('DTSTAMP:$stamp')..addAll(body)..add('END:VEVENT');

  if (trip.startDate != null && trip.endDate != null) {
    event('trip-${trip.id}', [
      'SUMMARY:${_icsEscape(trip.name)}',
      'DTSTART;VALUE=DATE:${_d8(trip.startDate!)}',
      'DTEND;VALUE=DATE:${_d8(addDays(trip.endDate!, 1))}',
      'TRANSP:TRANSPARENT',
    ]);
  }
  for (final e in events) {
    final place = e.placeId == null ? null : places[e.placeId];
    final body = <String>['SUMMARY:${_icsEscape(e.title)}'];
    if (e.endDate != null) {
      // ubytování od–do: celodenní, konec je „exkluzivní“ (den odjezdu)
      body
        ..add('DTSTART;VALUE=DATE:${_d8(e.date)}')
        ..add('DTEND;VALUE=DATE:${_d8(e.endDate!)}')
        ..add('TRANSP:TRANSPARENT');
    } else if (e.startMinutes != null) {
      final start = DateTime(e.date.year, e.date.month, e.date.day, 0, e.startMinutes!);
      body
        ..add('DTSTART:${_dt(start)}')
        ..add('DTEND:${_dt(start.add(const Duration(hours: 1)))}');
    } else {
      body
        ..add('DTSTART;VALUE=DATE:${_d8(e.date)}')
        ..add('DTEND;VALUE=DATE:${_d8(addDays(e.date, 1))}')
        ..add('TRANSP:TRANSPARENT');
    }
    if (place != null) {
      body.add('LOCATION:${_icsEscape(place.name)}');
      if (!(place.lat == 0 && place.lng == 0)) body.add('GEO:${place.lat};${place.lng}');
    }
    if (e.remindMinutes != null && e.startMinutes != null) {
      body.addAll([
        'BEGIN:VALARM',
        'ACTION:DISPLAY',
        'DESCRIPTION:${_icsEscape(e.title)}',
        'TRIGGER:-PT${e.remindMinutes}M',
        'END:VALARM',
      ]);
    }
    event(e.id, body);
  }
  lines.add('END:VCALENDAR');
  return '${lines.map(_fold).join('\r\n')}\r\n';
}

Future<void> exportTripIcs(AppDatabase db, String tripId) async {
  final d = await _load(db, tripId);
  final ics = buildTripIcs(d.trip, d.events, d.places);
  final f = await _write('${_safeName(d.trip.name)}.ics', utf8.encode(ics));
  await SharePlus.instance.share(ShareParams(
    files: [XFile(f.path, mimeType: 'text/calendar')],
    subject: d.trip.name,
  ));
}

// ---------------- PDF ----------------

Future<void> exportTripPdf(AppDatabase db, String tripId) async {
  final d = await _load(db, tripId);
  final bytes = await buildTripPdf(
    d,
    pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf')),
    pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Bold.ttf')),
  );
  final f = await _write('${_safeName(d.trip.name)}.pdf', bytes);
  await SharePlus.instance.share(ShareParams(
    files: [XFile(f.path, mimeType: 'application/pdf')],
    subject: d.trip.name,
  ));
}

/// Písmo v PDF (Noto Sans, latinka) nemá šipky a emoji → nahradit čitelnými znaky.
String _pdfText(String s) => s
    .replaceAll('→', '–')
    .replaceAll('←', '–')
    .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true), '')
    .trim();

/// PDF s plánem cesty (testovatelné bez telefonu).
Future<List<int>> buildTripPdf(TripData d, pw.Font regular, pw.Font bold) async {
  const accent = PdfColor.fromInt(0xFF0C8C6D);
  const muted = PdfColor.fromInt(0xFF5B6B67);

  final byDay = <DateTime, List<CalendarEvent>>{};
  for (final e in d.events) {
    byDay.putIfAbsent(dayOnly(e.date), () => []).add(e);
  }
  final days = byDay.keys.toList()..sort();
  final start = d.trip.startDate == null ? null : dayOnly(d.trip.startDate!);

  final total = d.expenses.fold<double>(0, (s, e) => s + (e.amountMain ?? 0));

  final doc = pw.Document(title: d.trip.name, author: 'Comes Viae');
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(36),
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
    footer: (ctx) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Comes Viae · LR Tech CZ', style: const pw.TextStyle(fontSize: 8, color: muted)),
        pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: muted)),
      ],
    ),
    build: (ctx) => [
      pw.Text(_pdfText(d.trip.name), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      if (d.trip.startDate != null && d.trip.endDate != null)
        pw.Text('${fmtDate(d.trip.startDate!)} – ${fmtDate(d.trip.endDate!)}',
            style: const pw.TextStyle(fontSize: 12, color: muted)),
      pw.SizedBox(height: 16),
      for (final day in days) ...[
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 10, bottom: 4),
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE6F4F0)),
          child: pw.Text(
            start == null
                ? fmtDay(day)
                : tr('Den {n} · {day}', {'n': day.difference(start).inDays + 1, 'day': fmtDay(day)}),
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: accent),
          ),
        ),
        for (final e in byDay[day]!)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 70,
                  child: pw.Text(e.startMinutes == null ? '' : fmtTime(e.startMinutes!),
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(_pdfText(e.title)),
                      if (e.endDate != null)
                        pw.Text(tr('Ubytování do {date}', {'date': fmtDate(e.endDate!)}),
                            style: const pw.TextStyle(fontSize: 9, color: muted)),
                      if (e.placeId != null && d.places[e.placeId] != null &&
                          d.places[e.placeId]!.name != e.title)
                        pw.Text(_pdfText(d.places[e.placeId]!.name),
                            style: const pw.TextStyle(fontSize: 9, color: muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
      if (d.docs.isNotEmpty) ...[
        pw.SizedBox(height: 18),
        pw.Text(tr('Doklady a rezervace'), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          cellStyle: const pw.TextStyle(fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE6F4F0)),
          headers: [tr('Doklad'), tr('Číslo'), tr('Rezervace'), tr('Odkud'), tr('Kam'), tr('Datum')],
          data: [
            for (final doc in d.docs)
              () {
                final t = d.tickets[doc.id];
                return [
                  _pdfText('${docTypes[doc.type] ?? doc.type}: ${doc.title}'),
                  t?.number ?? '',
                  t?.bookingRef ?? '',
                  t?.fromPlace ?? '',
                  t?.toPlace ?? '',
                  t?.departAt == null ? '' : fmtDate(t!.departAt!),
                ];
              }(),
          ],
        ),
      ],
      if (total > 0) ...[
        pw.SizedBox(height: 18),
        pw.Text(tr('Výdaje celkem: {total} {cur}', {'total': fmtMoney(total), 'cur': d.trip.mainCurrency}),
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
      ],
    ],
  ));
  return doc.save();
}
