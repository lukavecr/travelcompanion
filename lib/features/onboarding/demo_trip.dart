import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_settings.dart';
import '../../data/database.dart';
import '../../l10n/tr.dart';
import '../../core/format.dart';

/// Poznámka, podle které se pozná ukázková cesta (nepočítá se do limitů verze zdarma).
const demoTripNote = 'demo';

/// Vytvoří ukázkovou cestu do Japonska (za měsíc): plán, ubytování, místa s polohou, výdaje.
/// Vrací id cesty.
Future<String> createDemoTrip(AppDatabase db) async {
  const uuid = Uuid();
  final now = DateTime.now();
  final start = addDays(DateTime(now.year, now.month, now.day), 30);
  DateTime day(int n) => addDays(start, n - 1);
  final tripId = uuid.v4();

  await db.transaction(() async {
    await db.into(db.trips).insert(TripsCompanion.insert(
          id: tripId,
          name: tr('Ukázka: Japonsko'),
          startDate: Value(day(1)),
          endDate: Value(day(6)),
          notes: const Value(demoTripNote),
          countries: Value(jsonEncode(['Japonsko'])),
          mainCurrency: Value(AppSettings.instance.homeCurrency),
        ));

    Future<String> place(String name, double lat, double lng, String type) async {
      final id = uuid.v4();
      await db.into(db.places).insert(PlacesCompanion.insert(
            id: id,
            tripId: tripId,
            name: name,
            lat: lat,
            lng: lng,
            type: Value(type),
            country: const Value('Japonsko'),
          ));
      return id;
    }

    var order = 0;
    Future<void> event(int d, String title,
        {int? time, String? placeId, DateTime? until, int? remind}) async {
      await db.into(db.calendarEvents).insert(CalendarEventsCompanion.insert(
            id: uuid.v4(),
            tripId: tripId,
            date: day(d),
            sortOrder: Value(order++),
            title: title,
            placeId: Value(placeId),
            endDate: Value(until),
            startMinutes: Value(time),
            remindMinutes: Value(remind),
          ));
    }

    final hotelTokyo = await place('Hotel Gracery Shinjuku', 35.6945, 139.7019, 'hotel');
    final sensoji = await place('Sensō-ji', 35.7148, 139.7967, 'attraction');
    final shibuya = await place('Shibuya Crossing', 35.6595, 139.7005, 'attraction');
    final ramen = await place('Ichiran Shibuya', 35.6610, 139.7016, 'restaurant');
    final hotelKyoto = await place('Hotel Granvia Kyoto', 34.9858, 135.7588, 'hotel');
    final inari = await place('Fushimi Inari-taisha', 34.9671, 135.7727, 'attraction');
    final kinkaku = await place('Kinkaku-ji', 35.0394, 135.7292, 'attraction');

    await event(1, tr('Let Praha → Tokio'), time: 10 * 60 + 35, remind: 180);
    await event(1, 'Hotel Gracery Shinjuku', placeId: hotelTokyo, until: day(4));
    await event(2, 'Sensō-ji', time: 9 * 60, placeId: sensoji);
    await event(2, 'Shibuya Crossing', time: 18 * 60, placeId: shibuya);
    await event(2, tr('Večeře: ramen'), time: 19 * 60 + 30, placeId: ramen);
    await event(4, tr('Šinkansen Tokio → Kjóto'), time: 10 * 60, remind: 60);
    await event(4, 'Hotel Granvia Kyoto', placeId: hotelKyoto, until: day(6));
    await event(5, 'Fushimi Inari-taisha', time: 8 * 60, placeId: inari);
    await event(5, 'Kinkaku-ji', time: 14 * 60, placeId: kinkaku);

    Future<void> expense(int d, double amount, String category, String note) =>
        db.into(db.expenses).insert(ExpensesCompanion.insert(
              id: uuid.v4(),
              tripId: tripId,
              amount: amount,
              currency: 'JPY',
              category: Value(category),
              spentAt: day(d).add(const Duration(hours: 12)),
              country: const Value('Japonsko'),
              note: Value(note),
            ));
    await expense(2, 1280, 'food', 'Ichiran ramen');
    await expense(2, 3000, 'transport', 'Suica');
    await expense(5, 500, 'attractions', 'Kinkaku-ji');
  });
  return tripId;
}
