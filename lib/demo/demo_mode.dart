import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import '../core/format.dart';
import '../data/database.dart';
import '../features/onboarding/demo_trip.dart';
import '../features/tracks/tracker_service.dart' show encodePoints, trackLength, TrackPoint;
import '../features/vault/vault_crypto.dart';
import '../features/vault/vault_repository.dart';
import '../l10n/tr.dart';

/// Prezentační režim pro screenshoty a videa (Google Play, web, sociální sítě).
///
/// Sestavení: `flutter build apk --dart-define=TC_DEMO=true [--dart-define=TC_LANG=en]`.
/// Data jsou vymyšlená a jen v paměti (skutečná databáze se neotevře), záloha, sdílení a zámek
/// jsou vypnuté – do účtu přihlášeného v telefonu se nic nezapíše.
const kDemo = bool.fromEnvironment('TC_DEMO');
const kDemoLang = String.fromEnvironment('TC_LANG');

/// Vymyšlená data v jazyce screenshotů (cs, en, de, es).
String _l(String cs, String en, String de, String es) => switch (kDemoLang) {
      'en' => en,
      'de' => de,
      'es' => es,
      _ => cs,
    };

String get _japan => _l('Japonsko', 'Japan', 'Japan', 'Japón');

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Future<AppDatabase> openDemoDatabase() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  const uuid = Uuid();
  final today = dayOnly(DateTime.now());

  // hlavní cesta: Japonsko, právě probíhá (den 2)
  final japan = await createDemoTrip(db);
  final start = today.subtract(const Duration(days: 1));
  final shift = start.difference(
      (await (db.select(db.trips)..where((t) => t.id.equals(japan))).getSingle()).startDate!);
  await db.customUpdate(
      'UPDATE trips SET name = ?, notes = NULL, start_date = start_date + ?, end_date = end_date + ? WHERE id = ?',
      variables: [Variable(_japan), Variable(shift.inSeconds), Variable(shift.inSeconds), Variable(japan)],
      updates: {db.trips});
  for (final t in ['calendar_events']) {
    await db.customUpdate(
        'UPDATE $t SET date = date + ?, end_date = CASE WHEN end_date IS NULL THEN NULL ELSE end_date + ? END WHERE trip_id = ?',
        variables: [Variable(shift.inSeconds), Variable(shift.inSeconds), Variable(japan)],
        updates: {db.calendarEvents});
  }
  await db.customUpdate('UPDATE expenses SET spent_at = spent_at + ? WHERE trip_id = ?',
      variables: [Variable(shift.inSeconds), Variable(japan)], updates: {db.expenses});

  await db.customUpdate("UPDATE expenses SET amount_main = amount * 0.155, fx_rate = 0.155 WHERE currency = 'JPY'",
      updates: {db.expenses});
  await db.customUpdate('UPDATE expenses SET country = ? WHERE trip_id = ?',
      variables: [Variable(_japan), Variable(japan)], updates: {db.expenses});
  await db.customUpdate('UPDATE places SET country = ? WHERE trip_id = ?',
      variables: [Variable(_japan), Variable(japan)], updates: {db.places});
  await db.customUpdate('UPDATE trips SET countries = ? WHERE id = ?',
      variables: [Variable('["$_japan"]'), Variable(japan)], updates: {db.trips});

  // další výdaje (statistiky vypadají jako ze skutečné cesty)
  final rnd = Random(7);
  const cats = ['food', 'transport', 'lodging', 'attractions', 'shopping', 'food', 'food'];
  for (var i = 0; i < 14; i++) {
    final amount = (800 + rnd.nextInt(6000)).toDouble();
    await db.into(db.expenses).insert(ExpensesCompanion.insert(
          id: uuid.v4(),
          tripId: japan,
          amount: amount,
          currency: 'JPY',
          amountMain: Value(amount * 0.155),
          fxRate: const Value(0.155),
          category: Value(cats[i % cats.length]),
          spentAt: start.add(Duration(hours: 10 + i * 7)),
          country: Value(_japan),
        ));
  }

  // palubní lístek s kódem (BCBP)
  final docId = uuid.v4();
  final depart = start.add(const Duration(hours: 10, minutes: 35));
  await db.into(db.documents).insert(DocumentsCompanion.insert(
        id: docId,
        tripId: japan,
        type: 'flight',
        localPath: 'text:',
        title: Value(tr('Let {flight} {from} → {to}', {'flight': 'QR290', 'from': 'PRG', 'to': 'DOH'})),
        country: Value(_japan),
        ocrStatus: const Value('done'),
      ));
  await db.into(db.tickets).insert(TicketsCompanion.insert(
        id: uuid.v4(),
        documentId: docId,
        carrier: const Value('QR'),
        number: const Value('QR290'),
        bookingRef: const Value('X7KQ2P'),
        fromPlace: const Value('PRG'),
        toPlace: const Value('DOH'),
        departAt: Value(depart),
        passenger: const Value('NOVAK/JAN'),
        seat: const Value('24A'),
        gate: const Value('B12'),
        qrData: const Value('M1NOVAK/JAN           EX7KQ2P PRGDOHQR 0290 001Y024A0001 100'),
        barcodeFormat: const Value('pdf417'),
      ));
  final rail = uuid.v4();
  await db.into(db.documents).insert(DocumentsCompanion.insert(
        id: rail,
        tripId: japan,
        type: 'train',
        localPath: 'text:',
        title: Value(_l('Shinkansen Tokio → Kjóto', 'Shinkansen Tokyo → Kyoto', 'Shinkansen Tokio → Kyoto', 'Shinkansen Tokio → Kioto')),
        ocrStatus: const Value('done'),
      ));
  await db.into(db.tickets).insert(TicketsCompanion.insert(
        id: uuid.v4(),
        documentId: rail,
        number: const Value('Nozomi 21'),
        fromPlace: const Value('Tokyo'),
        toPlace: const Value('Kyoto'),
        departAt: Value(start.add(const Duration(days: 3, hours: 9, minutes: 30))),
        seat: const Value('7-12D'),
        qrData: const Value('JR-NOZOMI21-7-12D-TOKYO-KYOTO'),
        barcodeFormat: const Value('qr'),
      ));

  // další cesty v seznamu
  for (final (name, from, days, countries) in [
    (
      _l('Vietnam a Kambodža', 'Vietnam & Cambodia', 'Vietnam & Kambodscha', 'Vietnam y Camboya'),
      today.add(const Duration(days: 60)),
      28,
      '["Vietnam","${_l('Kambodža', 'Cambodia', 'Kambodscha', 'Camboya')}"]'
    ),
    (
      _l('Nový Zéland', 'New Zealand', 'Neuseeland', 'Nueva Zelanda'),
      today.add(const Duration(days: 140)),
      21,
      '["${_l('Nový Zéland', 'New Zealand', 'Neuseeland', 'Nueva Zelanda')}"]'
    ),
  ]) {
    await db.into(db.trips).insert(TripsCompanion.insert(
          id: uuid.v4(),
          name: name,
          startDate: Value(from),
          endDate: Value(from.add(Duration(days: days))),
          countries: Value(countries),
          mainCurrency: const Value('CZK'),
        ));
  }

  // zaznamenaná trasa: procházka v Asakuse
  final pts = <TrackPoint>[];
  var lat = 35.7110, lng = 139.7940;
  for (var i = 0; i < 40; i++) {
    lat += 0.00012 * (i < 20 ? 1 : -0.4) + (rnd.nextDouble() - 0.5) * 0.00008;
    lng += 0.00010 * (i < 20 ? 0.3 : 1) + (rnd.nextDouble() - 0.5) * 0.00008;
    pts.add((lat, lng, i * 75));
  }
  await db.into(db.tracks).insert(TracksCompanion.insert(
        id: uuid.v4(),
        tripId: Value(japan),
        name: _l('Asakusa a Sumida', 'Asakusa & Sumida', 'Asakusa & Sumida', 'Asakusa y Sumida'),
        startedAt: start.add(const Duration(hours: 15)),
        endedAt: Value(start.add(const Duration(hours: 15, minutes: 50))),
        distanceM: Value(trackLength(pts)),
        points: Value(encodePoints(pts)),
      ));

  // Vault s vymyšlenými údaji (klíč jen v paměti)
  VaultKeys.instance.useDemoKey();
  final vault = VaultRepository(db);
  final y = today.year;
  await vault.save(type: 'passport', photoIds: const [], fields: {
    'name': 'Jan Novák',
    'number': '45127890',
    'nationality': _l('Česká republika', 'Czech Republic', 'Tschechien', 'República Checa'),
    'birthDate': '1988-04-12',
    'issued': '${y - 6}-03-02',
    'validUntil': _ymd(today.add(const Duration(days: 150))),
  });
  await vault.save(type: 'insurance', photoIds: const [], fields: {
    'company': _l('Cestovní pojištění World', 'World Travel Insurance', 'Weltreise-Versicherung', 'Seguro de Viaje World'),
    'policy': 'CP-2027-004512',
    'assistance': '+420 221 000 111',
    'validFrom': _ymd(start),
    'validUntil': _ymd(start.add(const Duration(days: 365))),
  });
  await vault.save(type: 'visa', photoIds: const [], fields: {
    'country': 'Vietnam',
    'kind': 'e-visa',
    'number': 'E2700451236',
    'entries': '1',
    'validFrom': _ymd(today.add(const Duration(days: 60))),
    'validUntil': _ymd(today.add(const Duration(days: 150))),
    'maxStay': '90',
  });
  await vault.save(type: 'vaccination', photoIds: const [], fields: {
    'vaccine': _l('Žlutá zimnice', 'Yellow fever', 'Gelbfieber', 'Fiebre amarilla'),
    'date': '${y - 2}-05-10',
  });
  await vault.save(type: 'contact', photoIds: const [], fields: {
    'name': 'Eva Nováková',
    'relation': _l('manželka', 'wife', 'Ehefrau', 'esposa'),
    'phone': '+420 777 123 456',
  });
  await vault.save(type: 'medical', photoIds: const [], fields: {
    'name': 'Jan Novák',
    'bloodType': 'A+',
    'allergies': 'Penicillin',
  });
  return db;
}

