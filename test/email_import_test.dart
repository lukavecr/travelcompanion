import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/core/app_settings.dart';
import 'package:travelcompanion/features/documents/email_parser.dart';

void main() {
  setUp(() => AppSettings.instance.language = 'cs');

  test('letenka se dvěma lety (anglicky)', () {
    const mail = '''
Your trip is confirmed!
Booking reference: X7KQ2P
Passenger: ROMAN NOVAK

Outbound flight
Mon, 12 Nov 2026
Prague (PRG) → Doha (DOH)
Departure 14:25  Arrival 22:10
Flight QR 290 · Qatar Airways

Return flight
Sun, 25 Nov 2026
Doha (DOH) → Prague (PRG)
Departure 07:45
Flight QR 289
Total: EUR 812.40
''';
    expect(looksLikeBooking(mail), isTrue);
    final r = parseBookingText(mail);
    expect(r.length, 2);
    final a = r[0].fields, b = r[1].fields;
    expect(a['type'], 'flight');
    expect(a['flight'], 'QR290');
    expect(a['from'], 'PRG');
    expect(a['to'], 'DOH');
    expect(a['date'], '2026-11-12');
    expect(a['time'], '${14 * 60 + 25}');
    expect(a['ref'], 'X7KQ2P');
    expect(a['name'], 'ROMAN NOVAK');
    expect(b['flight'], 'QR289');
    expect(b['from'], 'DOH');
    expect(b['date'], '2026-11-25');
    expect(b['time'], '${7 * 60 + 45}');
  });

  test('česká letenka s datem slovy', () {
    const mail = '''
Potvrzení rezervace letenky
Kód rezervace: OK4ZTB
Let OK 800, odlet 3. prosince 2026 v 10:35
PRG – CDG
Cestující: Roman Novák
''';
    final r = parseBookingText(mail).single.fields;
    expect(r['flight'], 'OK800');
    expect(r['date'], '2026-12-03');
    expect(r['time'], '${10 * 60 + 35}');
    expect(r['from'], 'PRG');
    expect(r['to'], 'CDG');
    expect(r['ref'], 'OK4ZTB');
  });

  test('ubytování (Booking.com)', () {
    const mail = '''
Thanks, Roman! Your booking is confirmed at Hotel Gracery Shinjuku.
Booking number: 4021.558.913
Check-in Thursday, January 14, 2027 from 15:00
Check-out Sunday, January 17, 2027 until 11:00
Guest name: Roman Novak
''';
    expect(looksLikeBooking(mail), isTrue);
    final r = parseBookingText(mail).single.fields;
    expect(r['type'], 'hotel');
    expect(r['title'], 'Hotel Gracery Shinjuku');
    expect(r['date'], '2027-01-14');
    expect(r['endDate'], '2027-01-17');
    expect(r['time'], '${15 * 60}');
    expect(r['ref'], '4021.558.913');
  });

  test('německá Bahn jízdenka', () {
    const mail = '''
Ihre Buchung bei der Deutschen Bahn
Auftragsnummer / Buchungsnummer: 612345678901
Hinfahrt am 05.02.2027, Abfahrt 08:12 München Hbf
Zug ICE 1006
''';
    final r = parseBookingText(mail).single.fields;
    expect(r['type'], 'train');
    expect(r['date'], '2027-02-05');
    expect(r['time'], '${8 * 60 + 12}');
  });

  test('odkaz z Google Map se nepovažuje za rezervaci', () {
    expect(looksLikeBooking('Sensō-ji\nhttps://maps.app.goo.gl/abc123'), isFalse);
    expect(looksLikeBooking('Ahoj, zítra v 10:00 u nádraží?'), isFalse);
  });

  test('data v různých formátech', () {
    DateTime d(String s) => findDates(s).single.date;
    expect(d('12. 11. 2026'), DateTime(2026, 11, 12));
    expect(d('12 de noviembre de 2026'), DateTime(2026, 11, 12));
    expect(d('12. März 2027'), DateTime(2027, 3, 12));
    expect(d('November 3rd, 2026'), DateTime(2026, 11, 3));
    expect(findTimes('dep. 10:35 PM').single.$2, 22 * 60 + 35);
  });
}
