import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/app_settings.dart';
import '../../core/country_info.dart';
import '../../core/format.dart';
import '../../core/geocode.dart';
import '../../data/database.dart';
import '../tracks/tracker_service.dart' show distanceM;
import '../../l10n/tr.dart';

/// Plán cesty z AI (ChatGPT, Claude, Copilot…) ve formátu „travelcompanion-trip“ verze 1.
///
/// Uživatel zkopíruje zadání z aplikace ([buildAiPrompt]) do AI, ta na konci odpovědi vypíše
/// blok JSON a ten se vloží zpět (schránka, sdílení textu). [parseAiTrip] je tolerantní:
/// najde JSON i uprostřed textu, snese ```bloky```, čárky navíc, chybějící pole a dny bez data.
const aiTripFormat = 'travelcompanion-trip';

const aiTripTemplate = '''{
  "format": "travelcompanion-trip",
  "version": 1,
  "name": "Japan 2027",
  "startDate": "2027-04-01",
  "endDate": "2027-04-10",
  "countries": ["Japan"],
  "places": [
    {"id": "p1", "name": "Sensō-ji", "city": "Tokyo", "country": "Japan", "type": "attraction", "lat": 35.7148, "lng": 139.7967, "note": "Go early, fewer crowds"},
    {"id": "p2", "name": "Hotel Gracery Shinjuku", "city": "Tokyo", "country": "Japan", "type": "hotel", "lat": 35.6948, "lng": 139.7020}
  ],
  "stays": [
    {"name": "Hotel Gracery Shinjuku", "place": "p2", "checkIn": "2027-04-01", "checkOut": "2027-04-04"}
  ],
  "days": [
    {"date": "2027-04-01", "items": [
      {"time": "09:00", "title": "Sensō-ji temple", "place": "p1"},
      {"time": "13:00", "title": "Lunch: ramen in Asakusa"}
    ]}
  ]
}''';

/// Zadání pro AI v jazyce aplikace.
String buildAiPrompt({required String where, String? dates, String? likes}) {
  final b = StringBuffer()
    ..writeln(tr('Naplánuj mi cestu.'))
    ..writeln(tr('Kam: {where}', {'where': where}));
  if (dates != null && dates.isNotEmpty) b.writeln(tr('Termín: {dates}', {'dates': dates}));
  if (likes != null && likes.isNotEmpty) b.writeln(tr('Co mě baví / s kým jedu: {likes}', {'likes': likes}));
  b
    ..writeln()
    ..writeln(tr('Napiš podrobný plán po dnech: časy, místa, přesuny, ubytování a tipy.'))
    ..writeln()
    ..writeln(tr('Na úplný konec odpovědi přidej celý plán ještě jednou jako jeden blok kódu JSON přesně v tomto '
        'formátu (data RRRR-MM-DD, časy HH:MM, souřadnice desetinně; co nevíš, vynech). Každé místo z plánu dej '
        'do „places“ a odkaž na něj v položce dne přes „place“. Typ místa: attraction, restaurant, hotel, transport, other. '
        'Blok si vložím do aplikace Travel Companion.'))
    ..writeln('```json')
    ..writeln(aiTripTemplate)
    ..writeln('```');
  return b.toString();
}

// ---------- model ----------

class AiPlace {
  AiPlace({required this.key, required this.name, this.city, this.country, this.type = 'custom', this.lat, this.lng, this.note});
  final String key;
  final String name;
  final String? city, country, note;
  final String type;
  double? lat, lng;
  bool verified = false; // poloha potvrzená v OpenStreetMap
}

class AiItem {
  const AiItem(this.title, {this.minutes, this.placeKey});
  final String title;
  final int? minutes;
  final String? placeKey;
}

class AiDay {
  const AiDay(this.date, this.items);
  final DateTime date;
  final List<AiItem> items;
}

class AiStay {
  const AiStay(this.name, this.checkIn, this.checkOut, {this.placeKey});
  final String name;
  final DateTime checkIn, checkOut;
  final String? placeKey;
}

class AiTrip {
  AiTrip({required this.name, this.start, this.end, this.countries = const [], required this.places, required this.stays, required this.days});
  final String name;
  final DateTime? start, end;
  final List<String> countries;
  final List<AiPlace> places;
  final List<AiStay> stays;
  final List<AiDay> days;
  int get itemCount => days.fold(0, (s, d) => s + d.items.length);
}

// ---------- čtení ----------

/// Vypadá text jako plán z AI? (pro sdílený text)
bool looksLikeAiTrip(String text) => text.contains(aiTripFormat) || (text.contains('"days"') && text.contains('"places"'));

/// Najde v textu JSON objekt (blok ```json``` nebo první vyvážené {…}) a přečte ho.
Map<String, dynamic>? _findJson(String text) {
  final candidates = <String>[
    for (final m in RegExp(r'```(?:json|JSON)?\s*([\s\S]*?)```').allMatches(text)) m.group(1)!,
    text,
  ];
  for (final c in candidates) {
    var start = c.indexOf('{');
    while (start >= 0) {
      var depth = 0;
      var inStr = false;
      for (var i = start; i < c.length; i++) {
        final ch = c[i];
        if (inStr) {
          if (ch == '\\') {
            i++;
          } else if (ch == '"') {
            inStr = false;
          }
          continue;
        }
        if (ch == '"') inStr = true;
        if (ch == '{') depth++;
        if (ch == '}' && --depth == 0) {
          final raw = c.substring(start, i + 1);
          final j = _tryDecode(raw);
          if (j != null && (j.containsKey('days') || j.containsKey('places') || j['format'] == aiTripFormat)) return j;
          break;
        }
      }
      start = c.indexOf('{', start + 1);
    }
  }
  return null;
}

Map<String, dynamic>? _tryDecode(String raw) {
  // AI občas přidá čárku před ] nebo }, „chytré“ uvozovky nebo komentáře //
  final cleaned = raw
      .replaceAll(RegExp('[“”„]'), '"')
      .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '')
      .replaceAllMapped(RegExp(r',\s*([\]}])'), (m) => m.group(1)!);
  for (final s in [raw, cleaned]) {
    try {
      final v = jsonDecode(s);
      if (v is Map<String, dynamic>) return v;
    } catch (_) {}
  }
  return null;
}

DateTime? _date(Object? v) {
  if (v is! String) return null;
  final m = RegExp(r'(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(v);
  if (m == null) return null;
  return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
}

int? _time(Object? v) {
  if (v is! String) return null;
  final m = RegExp(r'(\d{1,2})[:.](\d{2})\s*([AaPp][Mm])?').firstMatch(v);
  if (m == null) return null;
  var h = int.parse(m.group(1)!);
  final min = int.parse(m.group(2)!);
  final ap = m.group(3)?.toLowerCase();
  if (ap == 'pm' && h < 12) h += 12;
  if (ap == 'am' && h == 12) h = 0;
  if (h > 23 || min > 59) return null;
  return h * 60 + min;
}

double? _num(Object? v) => v is num ? v.toDouble() : (v is String ? double.tryParse(v.replaceAll(',', '.')) : null);

String _type(Object? v) {
  final s = (v as String? ?? '').toLowerCase();
  if (s.contains('hotel') || s.contains('stay') || s.contains('accommodation') || s.contains('hostel')) return 'hotel';
  if (s.contains('rest') || s.contains('food') || s.contains('cafe') || s.contains('bar')) return 'restaurant';
  if (s.contains('transport') || s.contains('station') || s.contains('airport')) return 'transport';
  if (s.contains('attraction') || s.contains('sight') || s.contains('museum') || s.contains('temple') || s.contains('nature')) {
    return 'attraction';
  }
  return 'custom';
}

String _country(String c) => localCountryName(c, lang: AppSettings.instance.effectiveLanguage);

String? _str(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;

/// Přečte plán z AI. Vrátí null, když v textu žádný plán není.
AiTrip? parseAiTrip(String text) {
  final j = _findJson(text);
  if (j == null) return null;

  final places = <AiPlace>[];
  for (final (i, p) in ((j['places'] as List?) ?? const []).whereType<Map>().indexed) {
    final name = _str(p['name']);
    if (name == null) continue;
    places.add(AiPlace(
      key: _str(p['id']) ?? 'p$i',
      name: name,
      city: _str(p['city']),
      country: _str(p['country']),
      type: _type(p['type']),
      lat: _num(p['lat'] ?? p['latitude']),
      lng: _num(p['lng'] ?? p['lon'] ?? p['longitude']),
      note: _str(p['note'] ?? p['description']),
    ));
  }
  String? placeKey(Object? ref) {
    final r = _str(ref);
    if (r == null) return null;
    for (final p in places) {
      if (p.key == r) return p.key;
    }
    for (final p in places) {
      if (p.name.toLowerCase() == r.toLowerCase()) return p.key;
    }
    return null;
  }

  var start = _date(j['startDate'] ?? j['start']);
  final rawDays = ((j['days'] as List?) ?? const []).whereType<Map>().toList();
  // start z prvního dne s datem, aby šly dopočítat dny zadané jen číslem („day“: 3)
  if (start == null) {
    for (final d in rawDays) {
      final dt = _date(d['date']);
      if (dt != null) {
        final n = (_num(d['day']) ?? 1).toInt();
        start = dt.subtract(Duration(days: n - 1));
        break;
      }
    }
  }
  final days = <AiDay>[];
  for (final (i, d) in rawDays.indexed) {
    final n = (_num(d['day']) ?? (i + 1)).toInt();
    final date = _date(d['date']) ?? (start?.add(Duration(days: n - 1)));
    if (date == null) continue;
    final items = <AiItem>[
      for (final it in ((d['items'] as List?) ?? (d['activities'] as List?) ?? const []))
        if (it is Map && _str(it['title'] ?? it['name'] ?? it['activity']) != null)
          AiItem(_str(it['title'] ?? it['name'] ?? it['activity'])!,
              minutes: _time(it['time'] ?? it['start']), placeKey: placeKey(it['place'] ?? it['placeId']))
        else if (it is String && it.trim().isNotEmpty)
          AiItem(it.trim(), minutes: _time(it)),
    ];
    days.add(AiDay(date, items));
  }

  final stays = <AiStay>[];
  for (final s in ((j['stays'] as List?) ?? const []).whereType<Map>()) {
    final a = _date(s['checkIn'] ?? s['from']), b = _date(s['checkOut'] ?? s['to']);
    final name = _str(s['name']) ?? (placeKey(s['place']) != null
        ? places.firstWhere((p) => p.key == placeKey(s['place'])).name
        : null);
    if (a == null || b == null || name == null || b.isBefore(a)) continue;
    var key = placeKey(s['place']) ?? placeKey(name);
    if (key == null) {
      // ubytování bez místa → přidat místo, ať je na mapě
      key = 'stay${stays.length}';
      places.add(AiPlace(key: key, name: name, city: _str(s['city']), country: _str(s['country']), type: 'hotel'));
    }
    stays.add(AiStay(name, a, b, placeKey: key));
  }

  final dates = [
    for (final d in days) d.date,
    for (final s in stays) ...[s.checkIn, s.checkOut],
  ]..sort();
  final countries = <String>{
    for (final c in ((j['countries'] as List?) ?? const []).whereType<String>()) _country(c),
    for (final p in places)
      if (p.country != null) _country(p.country!),
  }.toList();

  if (days.isEmpty && places.isEmpty) return null;
  return AiTrip(
    name: _str(j['name'] ?? j['title']) ?? tr('Cesta z AI'),
    start: start ?? (dates.isEmpty ? null : dates.first),
    end: _date(j['endDate'] ?? j['end']) ?? (dates.isEmpty ? null : dates.last),
    countries: countries,
    places: places,
    stays: stays,
    days: days,
  );
}

// ---------- ověření polohy a zápis ----------

typedef Geocoder = Future<List<GeoResult>> Function(String query);

/// Dohledá polohu míst v OpenStreetMap podle názvu a města. Souřadnice od AI se ponechají,
/// když jsou do 1,5 km od nalezeného místa (nebo když OpenStreetMap nic nenajde).
Future<void> verifyPlaces(AiTrip t, {Geocoder geocode = searchPlaces, void Function(int done, int total)? onProgress}) async {
  for (final (i, p) in t.places.indexed) {
    onProgress?.call(i, t.places.length);
    final q = [p.name, p.city, p.country].whereType<String>().join(', ');
    GeoResult? hit;
    try {
      final r = await geocode(q);
      if (r.isEmpty && p.city != null) {
        // „Ramen v Asakuse, Tokyo“ nic nenajde → aspoň obec
        hit = (await geocode([p.name, p.country].whereType<String>().join(', '))).firstOrNull;
      } else {
        hit = r.firstOrNull;
      }
    } catch (_) {}
    if (hit == null) continue;
    final ai = p.lat != null && p.lng != null && (p.lat != 0 || p.lng != 0);
    if (!ai || distanceM(p.lat!, p.lng!, hit.lat, hit.lng) > 1500) {
      p.lat = hit.lat;
      p.lng = hit.lng;
    }
    p.verified = true;
  }
  onProgress?.call(t.places.length, t.places.length);
}

/// Vytvoří cestu, místa, plán a ubytování. Vrací id cesty.
Future<String> importAiTrip(AppDatabase db, AiTrip t) async {
  const uuid = Uuid();
  final tripId = uuid.v4();
  final ids = <String, String>{};
  await db.transaction(() async {
    await db.into(db.trips).insert(TripsCompanion.insert(
          id: tripId,
          name: t.name,
          startDate: Value(t.start),
          endDate: Value(t.end),
          countries: Value(jsonEncode(t.countries)),
          mainCurrency: Value(AppSettings.instance.homeCurrency),
        ));
    for (final p in t.places) {
      final id = uuid.v4();
      ids[p.key] = id;
      await db.into(db.places).insert(PlacesCompanion.insert(
            id: id,
            tripId: tripId,
            name: p.name,
            lat: p.lat ?? 0,
            lng: p.lng ?? 0,
            type: Value(p.type),
            country: Value(p.country == null ? null : _country(p.country!)),
            note: Value(p.note),
          ));
    }
    for (final s in t.stays) {
      await db.into(db.calendarEvents).insert(CalendarEventsCompanion.insert(
            id: uuid.v4(),
            tripId: tripId,
            date: dayOnly(s.checkIn),
            endDate: Value(dayOnly(s.checkOut)),
            title: s.name,
            placeId: Value(ids[s.placeKey]),
          ));
    }
    for (final d in t.days) {
      for (final (i, it) in d.items.indexed) {
        // ubytování už je v „stays“ – stejnou položku v dni nezdvojovat
        if (t.stays.any((s) => s.name == it.title && dayOnly(s.checkIn) == dayOnly(d.date))) continue;
        await db.into(db.calendarEvents).insert(CalendarEventsCompanion.insert(
              id: uuid.v4(),
              tripId: tripId,
              date: dayOnly(d.date),
              title: it.title,
              sortOrder: Value(i),
              startMinutes: Value(it.minutes),
              placeId: Value(ids[it.placeKey]),
            ));
      }
    }
  });
  return tripId;
}
