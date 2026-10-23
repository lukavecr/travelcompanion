import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/core/app_settings.dart';
import 'package:travelcompanion/data/database.dart';
import 'package:travelcompanion/features/reminders/trip_reminders.dart';
import 'package:travelcompanion/features/sync/backup_crypto.dart';
import 'package:travelcompanion/features/trips/trip_export.dart';

void main() {
  setUp(() => AppSettings.instance.language = 'cs');

  test('šifrovaná záloha: řádek tam a zpět, v cloudu nic čitelného', () async {
    final key = SecretKey(List.generate(32, (i) => i));
    final row = {
      'id': 'a1',
      'updatedAt': 1700000000000,
      'deletedAt': null,
      'name': 'Vietnam',
      'notes': 'pas č. 45123456',
    };
    final doc = await BackupCrypto.encryptRowWith(key, row);
    expect(doc.keys.toSet(), {'id', 'updatedAt', 'deletedAt', 'enc'});
    expect(doc['enc'].toString().contains('Vietnam'), isFalse);
    expect(await BackupCrypto.decryptRowWith(key, doc), row);
    final wrong = SecretKey(List.filled(32, 7));
    expect(() => BackupCrypto.decryptRowWith(wrong, doc), throwsA(isA<SecretBoxAuthenticationError>()));
  });

  final trip = Trip(
    id: 't1',
    updatedAt: DateTime(2026),
    syncState: 'synced',
    name: 'Japonsko, jaro',
    startDate: DateTime(2027, 4, 1),
    endDate: DateTime(2027, 4, 5),
    mainCurrency: 'CZK',
    countries: '[]',
  );
  CalendarEvent ev(String id, DateTime date, String title, {int? time, DateTime? until, int? remind}) =>
      CalendarEvent(
        id: id,
        updatedAt: DateTime(2026),
        syncState: 'synced',
        tripId: 't1',
        date: date,
        sortOrder: 0,
        title: title,
        endDate: until,
        startMinutes: time,
        remindMinutes: remind,
      );

  test('export do kalendáře (ICS)', () {
    final ics = buildTripIcs(trip, [
      ev('e1', DateTime(2027, 4, 1), 'Let Praha → Tokio', time: 10 * 60 + 35, remind: 120),
      ev('e2', DateTime(2027, 4, 1), 'Hotel; Shinjuku', until: DateTime(2027, 4, 4)),
    ], {});
    expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(ics, contains('DTSTART;VALUE=DATE:20270401\r\nDTEND;VALUE=DATE:20270406')); // celá cesta
    expect(ics, contains('DTSTART:20270401T103500'));
    expect(ics, contains('TRIGGER:-PT120M'));
    expect(ics, contains('SUMMARY:Hotel\\; Shinjuku'));
    expect(ics, contains('DTEND;VALUE=DATE:20270404'));
    expect(ics.trim(), endsWith('END:VCALENDAR'));
  });

  test('upozornění na cestu: check-in, odlet, odjezd z ubytování', () {
    final doc = Document(
      id: 'd1', updatedAt: DateTime(2026), syncState: 'synced', tripId: 't1', type: 'flight',
      localPath: '', ocrStatus: 'done', title: 'Letenka',
    );
    final ticket = Ticket(
      id: 'k1', updatedAt: DateTime(2026), syncState: 'synced', documentId: 'd1',
      number: 'ok800', fromPlace: 'prg', departAt: DateTime(2027, 4, 1, 10, 35),
    );
    final r = buildTripReminders(
      [(ticket, doc)],
      [ev('e2', DateTime(2027, 4, 1), 'Hotel Shinjuku', until: DateTime(2027, 4, 4))],
    );
    expect(r.map((x) => x.fire), [
      DateTime(2027, 3, 31, 10, 35),
      DateTime(2027, 4, 1, 7, 35),
      DateTime(2027, 4, 4, 8),
    ]);
    expect(r.first.title, '✈ OK800: online check-in');
    expect(r.first.body, contains('z PRG'));
    expect(r.last.title, '🏨 Dnes odjezd: Hotel Shinjuku');
  });
}
