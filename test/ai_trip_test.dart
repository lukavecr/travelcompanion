import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/core/app_settings.dart';
import 'package:travelcompanion/core/geocode.dart';
import 'package:travelcompanion/data/database.dart';
import 'package:travelcompanion/features/ai_plan/ai_trip.dart';

const _answer = '''
Tady je tvůj plán na 3 dny v Lisabonu! 🇵🇹

**Den 1** – Alfama, Belém…

```json
{
  "format": "travelcompanion-trip",
  "version": 1,
  "name": "Lisabon na prodloužený víkend",
  "startDate": "2027-05-14",
  "endDate": "2027-05-16",
  "countries": ["Portugal"],
  "places": [
    {"id": "p1", "name": "Torre de Belém", "city": "Lisbon", "country": "Portugal", "type": "attraction", "lat": 38.6916, "lng": -9.2160},
    {"id": "p2", "name": "Pastéis de Belém", "city": "Lisbon", "country": "Portugal", "type": "food"},
    {"id": "p3", "name": "Castelo de São Jorge", "city": "Lisbon", "country": "Portugal", "type": "sight", "lat": 38.80, "lng": -9.10},
  ],
  "stays": [
    {"name": "Lisboa Pessoa Hotel", "checkIn": "2027-05-14", "checkOut": "2027-05-16"}
  ],
  "days": [
    {"date": "2027-05-14", "items": [
      {"time": "10:00", "title": "Torre de Belém", "place": "p1"},
      {"time": "12:30", "title": "Pastéis de nata", "place": "Pastéis de Belém"},
      {"title": "Lisboa Pessoa Hotel"}
    ]},
    {"day": 2, "items": [{"time": "9:30 AM", "title": "Hrad", "place": "p3"}, "Tramvaj 28 přes Alfamu"]}
  ]
}
```
Užij si to!
''';

void main() {
  setUp(() => AppSettings.instance.language = 'cs');

  test('přečte odpověď AI i s chybami (čárka navíc, den bez data, místo podle názvu)', () {
    expect(looksLikeAiTrip(_answer), isTrue);
    final t = parseAiTrip(_answer)!;
    expect(t.name, 'Lisabon na prodloužený víkend');
    expect(t.start, DateTime(2027, 5, 14));
    expect(t.end, DateTime(2027, 5, 16));
    expect(t.countries, ['Portugalsko']);
    expect(t.places.length, 4); // 3 + hotel z „stays“
    expect(t.places[1].type, 'restaurant');
    expect(t.places[2].type, 'attraction');
    expect(t.days.length, 2);
    expect(t.days[1].date, DateTime(2027, 5, 15));
    expect(t.days[1].items[0].minutes, 9 * 60 + 30);
    expect(t.days[1].items[1].title, 'Tramvaj 28 přes Alfamu');
    expect(t.days[0].items[1].placeKey, 'p2');
    expect(t.stays.single.placeKey, isNotNull);
  });

  test('bez plánu → null; pokyn pro AI obsahuje sloupce', () {
    expect(parseAiTrip('Ahoj, jak se máš? {"a": 1}'), isNull);
    final p = buildAiCsvInstruction();
    expect(p, contains(aiCsvColumns));
    expect(parseAiTrip(p)!.name, 'Vietnam 2026'); // ukázka v pokynu je sama platný soubor
  });

  test('ověření polohy a zápis do databáze', () async {
    final t = parseAiTrip(_answer)!;
    final queries = <String>[];
    Future<List<GeoResult>> fake(String q) async {
      queries.add(q);
      if (q.startsWith('Castelo')) {
        return const [GeoResult(name: 'Castelo', address: '', lat: 38.7139, lng: -9.1335)];
      }
      if (q.startsWith('Torre')) {
        return const [GeoResult(name: 'Torre', address: '', lat: 38.6915, lng: -9.2159)];
      }
      return const [];
    }

    await verifyPlaces(t, geocode: fake);
    expect(t.places[0].lat, 38.6916); // AI trefila (do 1,5 km) → ponechat
    expect(t.places[2].lat, 38.7139); // AI vedle → OpenStreetMap
    expect(t.places[1].lat, isNull); // nenalezeno → doplní se později
    expect(queries.first, 'Torre de Belém, Lisbon, Portugal');

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final id = await importAiTrip(db, t);
    final trip = await (db.select(db.trips)..where((x) => x.id.equals(id))).getSingle();
    expect(trip.name, 'Lisabon na prodloužený víkend');
    final ev = await (db.select(db.calendarEvents)..where((x) => x.tripId.equals(id))).get();
    expect(ev.where((e) => e.endDate != null).length, 1); // ubytování od–do
    expect(ev.length, 1 + 2 + 2); // hotel jen jednou, ne i v položkách dne
    final places = await db.select(db.places).get();
    expect(places.length, 4);
    expect(places.where((p) => p.lat == 0).length, 2); // pastéis + hotel bez polohy
    await db.close();
  });

  test('CSV od AI: ubytování od–do, místa, uvozovky, čas', () {
    const csv = '﻿trip,date,time,title,place,city,country,type,lat,lng,end_date,note\n'
        'Vietnam 2026,2026-12-08,,Hotel in the Old Quarter,Hanoi La Siesta Hotel,Hanoi,Vietnam,hotel,21.0340,105.8500,2026-12-11,\n'
        'Vietnam 2026,2026-12-09,09:00,Walk around Hoan Kiem Lake,Hoan Kiem Lake,Hanoi,Vietnam,attraction,21.0287,105.8524,,"Best early, locals do tai chi"\n'
        'Vietnam 2026,2026-12-09,07:30,Pho breakfast,Pho Gia Truyen,Hanoi,Vietnam,restaurant,,,,\n'
        'Vietnam 2026,2026-12-10,,Train to Sapa,,,,transport,,,,\n';
    expect(looksLikeAiTrip(csv), isTrue);
    final t = parseAiTrip(csv)!;
    expect(t.name, 'Vietnam 2026');
    expect(t.start, DateTime(2026, 12, 8));
    expect(t.end, DateTime(2026, 12, 11));
    expect(t.countries, ['Vietnam']);
    expect(t.stays.single.checkOut, DateTime(2026, 12, 11));
    expect(t.places.length, 3);
    expect(t.places[1].note, 'Best early, locals do tai chi');
    expect(t.days.length, 2);
    expect(t.days[0].items.map((i) => i.title), ['Pho breakfast', 'Walk around Hoan Kiem Lake']); // podle času
    expect(t.days[1].items.single.placeKey, isNull);
  });

  test('CSV z Excelu (středník, české hlavičky, blok ```csv v odpovědi)', () {
    const answer = 'Tady je soubor:\n```csv\n'
        'Datum;Čas;Název;Místo;Město;Země;Typ;Do\n'
        '2027-01-25;10:00;Velký palác;Grand Palace;Bangkok;Thailand;attraction;\n'
        '2027-01-25;;Hostel;Lub d Silom;Bangkok;Thailand;hotel;2027-01-28\n'
        '```\nHezkou cestu!';
    final t = parseAiTrip(answer)!;
    expect(t.countries, ['Thajsko']);
    expect(t.days.single.items.single.minutes, 600);
    expect(t.stays.single.name, 'Lub d Silom');
    expect(t.end, DateTime(2027, 1, 28));
  });
}
