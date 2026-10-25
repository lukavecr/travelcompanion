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

/// Plán cesty z AI (ChatGPT, Claude, Copilot, Gemini…).
///
/// Uživatel napíše AI, kam a kdy jede, přidá pokyn z aplikace ([buildAiCsvInstruction]) a AI vytvoří
/// soubor CSV ([aiCsvColumns]), který se v aplikaci importuje. Čte se i starší JSON „travelcompanion-trip“ v1
/// a text odpovědi s blokem kódu. [parseAiTrip] je tolerantní k textu kolem, středníkům z Excelu a chybějícím polím.
const aiTripFormat = 'travelcompanion-trip';

// ---------- model ----------

class AiPlace {
  AiPlace({
    required this.key,
    required this.name,
    this.city,
    this.country,
    this.type = 'custom',
    this.lat,
    this.lng,
    this.note,
    this.optional = false,
  });
  final String key;
  final String name;
  final String? city, note;
  String? country; // když chybí, doplní se z OpenStreetMap
  final String type;
  double? lat, lng;
  bool verified = false; // poloha potvrzená v OpenStreetMap
  /// Odhad z volného textu („Temple of Literature“) – na mapu jen, když ho OpenStreetMap najde.
  final bool optional;
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
bool looksLikeAiTrip(String text) =>
    text.contains(aiTripFormat) || (text.contains('"days"') && text.contains('"places"')) || _csvHeader(text) != null;

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

/// Přečte plán z AI – soubor CSV (doporučený) nebo JSON. Vrátí null, když v textu žádný plán není.
AiTrip? parseAiTrip(String text, {String? fileName}) {
  final j = _findJson(text);
  if (j == null) return parseAiCsv(text, fileName: fileName);

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
        start = addDays(dt, -(n - 1));
        break;
      }
    }
  }
  final days = <AiDay>[];
  for (final (i, d) in rawDays.indexed) {
    final n = (_num(d['day']) ?? (i + 1)).toInt();
    final date = _date(d['date']) ?? (start == null ? null : addDays(start, n - 1));
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
  final cache = <String, List<GeoResult>>{};
  final areas = <String, (double, double)>{}; // oblast (nocleh) → poloha
  Future<List<GeoResult>> look(String q) async => cache[q] ??= await geocode(q);
  for (final (i, p) in t.places.indexed) {
    onProgress?.call(i, t.places.length);
    final q = [p.name, p.city, p.country].whereType<String>().join(', ');
    GeoResult? hit;
    try {
      final r = await look(q);
      if (r.isEmpty && p.city != null && !p.optional) {
        // „Ramen v Asakuse, Tokyo“ nic nenajde → aspoň obec
        hit = (await look([p.name, p.country].whereType<String>().join(', '))).firstOrNull;
      } else {
        hit = r.firstOrNull;
      }
    } catch (_) {}
    if (hit == null) continue;
    // místo odhadnuté z textu musí ležet u své oblasti („Staré město, Hanoi“ nesmí skončit v Česku)
    final base = areas[p.city?.toLowerCase()];
    if (p.optional && base != null && distanceM(base.$1, base.$2, hit.lat, hit.lng) > 150000) continue;
    p.country ??= hit.country;
    final ai = p.lat != null && p.lng != null && (p.lat != 0 || p.lng != 0);
    if (!ai || distanceM(p.lat!, p.lng!, hit.lat, hit.lng) > 1500) {
      p.lat = hit.lat;
      p.lng = hit.lng;
    }
    p.verified = true;
    if (p.key.startsWith('area|')) areas[p.name.toLowerCase()] = (p.lat!, p.lng!);
  }
  onProgress?.call(t.places.length, t.places.length);
}

/// Vytvoří cestu, místa, plán a ubytování. Vrací id cesty.
Future<String> importAiTrip(AppDatabase db, AiTrip t) async {
  const uuid = Uuid();
  final tripId = uuid.v4();
  final ids = <String, String>{};
  final places = t.places.where((p) => !p.optional || p.lat != null).toList();
  final countries = t.countries.isNotEmpty
      ? t.countries
      : {for (final p in places) if (p.country != null) _country(p.country!)}.toList();
  await db.transaction(() async {
    await db.into(db.trips).insert(TripsCompanion.insert(
          id: tripId,
          name: t.name,
          startDate: Value(t.start),
          endDate: Value(t.end),
          countries: Value(jsonEncode(countries)),
          mainCurrency: Value(AppSettings.instance.homeCurrency),
        ));
    for (final p in places) {
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


// ---------- CSV (doporučený formát: AI ho umí vytvořit jako soubor ke stažení) ----------

/// Sloupce souboru CSV v tomto pořadí (jeden řádek = jedna položka plánu).
const aiCsvColumns = 'trip,date,time,title,place,city,country,type,lat,lng,end_date,note';

/// Ukázka souboru (3 řádky) – je i součástí pokynu pro AI.
const aiCsvExample = '''trip,date,time,title,place,city,country,type,lat,lng,end_date,note
Vietnam 2026,2026-12-08,,Hotel in the Old Quarter,Hanoi La Siesta Hotel,Hanoi,Vietnam,hotel,21.0340,105.8500,2026-12-11,
Vietnam 2026,2026-12-09,09:00,Walk around Hoan Kiem Lake,Hoan Kiem Lake,Hanoi,Vietnam,attraction,21.0287,105.8524,,"Best early, locals do tai chi"''';

/// Pokyn pro AI, který si uživatel zkopíruje za svou zprávu („Jedu do Vietnamu 8. 12. – 15. 1. …“).
String buildAiCsvInstruction() => [
      tr('Vytvoř detailní plán cesty den po dni s konkrétními zajímavými místy, ubytováním a přesuny.'),
      tr('Celý plán mi dej jako soubor CSV ke stažení (kódování UTF-8, oddělovač čárka, první řádek jsou názvy sloupců) s těmito sloupci v tomto pořadí:'),
      aiCsvColumns,
      tr('Pravidla: jeden řádek = jedna položka plánu; trip = název cesty (v každém řádku stejný); date = RRRR-MM-DD; '
          'time = HH:MM (může chybět); title = co se dělá; place = název konkrétního místa pro mapu; city a country anglicky; '
          'type = attraction, restaurant, hotel, transport nebo other; lat a lng = souřadnice místa desetinně; '
          'ubytování jako jeden řádek s type = hotel, date = den příjezdu a end_date = den odjezdu; note = krátký tip. '
          'Texty s čárkou dej do uvozovek.'),
      tr('Ukázka:'),
      aiCsvExample,
    ].join('\n');

const _csvAliases = <String, List<String>>{
  'trip': ['trip', 'trip_name', 'trip name', 'cesta', 'reise', 'viaje'],
  'date': ['date', 'datum', 'day_date', 'fecha'],
  'time': ['time', 'start_time', 'čas', 'cas', 'zeit', 'hora'],
  'title': ['title', 'activity', 'název', 'nazev', 'aktivita', 'titel', 'aktivität', 'actividad', 'titulo', 'título'],
  'place': ['place', 'place_name', 'location', 'místo', 'misto', 'ort', 'lugar'],
  'city': ['city', 'město', 'mesto', 'stadt', 'ciudad'],
  'country': ['country', 'země', 'zeme', 'land', 'país', 'pais'],
  'type': ['type', 'typ', 'category', 'kategorie', 'tipo'],
  'lat': ['lat', 'latitude'],
  'lng': ['lng', 'lon', 'long', 'longitude'],
  'end_date': ['end_date', 'enddate', 'end', 'check_out', 'checkout', 'do', 'odjezd'],
  'note': ['note', 'notes', 'poznámka', 'poznamka', 'tip', 'tips', 'description', 'notiz', 'nota'],
};

/// Sloupce volného itineráře, jak ho AI napíše bez vzoru (stačí část názvu: „Oblast / nocleh“).
const _freeAliases = <String, List<String>>{
  'program': ['program', 'activit', 'aktivit', 'itiner', 'plan', 'plán', 'popis', 'description', 'sights', 'místa',
      'places', 'what to do', 'co dělat', 'highlights', 'náplň'],
  'area': ['nocleh', 'ubytování', 'overnight', 'accommodation', 'stay', 'base', 'oblast', 'region', 'area', 'destinace',
      'destination', 'město', 'city', 'location', 'lokalita', 'kde'],
  'transport': ['doprava', 'transport', 'přesun', 'travel'],
  'note': ['poznámk', 'note', 'tip', 'comment', 'komentář'],
};

/// Je řádek hlavičkou CSV plánu? Vrací (oddělovač, sloupec → index, volný itinerář?).
(String, Map<String, int>, bool)? _csvHeaderLine(String raw) {
  final line = raw.replaceFirst('\ufeff', '').trim();
  if (line.isEmpty) return null;
  final sep = [',', ';', '\t'].reduce((a, b) => line.split(a).length >= line.split(b).length ? a : b);
  final cells = _csvLine(line, sep).map((c) => c.trim().toLowerCase()).toList();
  final idx = <String, int>{};
  for (final e in _csvAliases.entries) {
    final i = cells.indexWhere(e.value.contains);
    if (i >= 0) idx[e.key] = i;
  }
  if (!idx.containsKey('date')) return null;
  if (idx.containsKey('title') || idx.containsKey('place')) return (sep, idx, false);
  // volný itinerář: sloupce hledáme podle části názvu
  final free = <String, int>{'date': idx['date']!};
  for (final e in _freeAliases.entries) {
    final i = cells.indexWhere((c) => !free.containsValue(cells.indexOf(c)) && e.value.any(c.contains));
    if (i >= 0 && !free.containsValue(i)) free[e.key] = i;
  }
  return free.containsKey('program') || free.containsKey('area') ? (sep, free, true) : null;
}

(String, Map<String, int>, bool)? _csvHeader(String text) {
  for (final line in text.split(RegExp(r'\r?\n')).take(30)) {
    final h = _csvHeaderLine(line);
    if (h != null) return h;
  }
  return null;
}

/// Jeden řádek CSV s uvozovkami ("a, b" i "" uvnitř).
List<String> _csvLine(String line, String sep) {
  final out = <String>[];
  final b = StringBuffer();
  var q = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (q) {
      if (ch == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          b.write('"');
          i++;
        } else {
          q = false;
        }
      } else {
        b.write(ch);
      }
    } else if (ch == '"') {
      q = true;
    } else if (ch == sep) {
      out.add(b.toString());
      b.clear();
    } else {
      b.write(ch);
    }
  }
  out.add(b.toString());
  return out;
}

/// Řádky CSV (uvozovky můžou obsahovat i konec řádku).
List<String> _csvRows(String text) {
  final rows = <String>[];
  final b = StringBuffer();
  var q = false;
  for (final ch in text.replaceAll('\r\n', '\n').split('')) {
    if (ch == '"') q = !q;
    if (ch == '\n' && !q) {
      rows.add(b.toString());
      b.clear();
    } else {
      b.write(ch);
    }
  }
  if (b.isNotEmpty) rows.add(b.toString());
  return rows;
}

/// Plán ze souboru CSV od AI. Vrací null, když to CSV plánu není.
AiTrip? parseAiCsv(String text, {String? fileName}) {
  // AI občas dá CSV do bloku ```csv
  final block = RegExp(r'```(?:csv|CSV)?\s*([\s\S]*?)```').firstMatch(text)?.group(1);
  final src = (block != null && _csvHeader(block) != null) ? block : text;
  final rows = _csvRows(src.replaceFirst('\ufeff', ''));
  final headerAt = rows.indexWhere((r) => _csvHeaderLine(r) != null);
  if (headerAt < 0) return null;
  final (sep, idx, free) = _csvHeaderLine(rows[headerAt])!;
  if (free) return _parseFreeCsv(rows.skip(headerAt + 1), sep, idx, fileName);

  String? cell(List<String> c, String k) {
    final i = idx[k];
    if (i == null || i >= c.length) return null;
    final v = c[i].trim();
    return v.isEmpty ? null : v;
  }

  String? tripName;
  final places = <String, AiPlace>{};
  final stays = <AiStay>[];
  final byDay = <DateTime, List<AiItem>>{};

  for (final r in rows.skip(headerAt + 1)) {
    if (r.trim().isEmpty) continue;
    final c = _csvLine(r, sep);
    final date = _date(cell(c, 'date'));
    if (date == null) continue;
    tripName ??= cell(c, 'trip');
    final title = cell(c, 'title');
    final placeName = cell(c, 'place');
    final type = _type(cell(c, 'type'));
    final end = _date(cell(c, 'end_date'));
    final name = placeName ?? title;
    if (name == null) continue;

    String? key;
    if (placeName != null || type == 'hotel') {
      final city = cell(c, 'city');
      final k = '${name.toLowerCase()}|${(city ?? '').toLowerCase()}';
      key = k;
      places.putIfAbsent(
          k,
          () => AiPlace(
                key: k,
                name: name,
                city: city,
                country: cell(c, 'country'),
                type: type,
                lat: _num(cell(c, 'lat')),
                lng: _num(cell(c, 'lng')),
                note: cell(c, 'note'),
              ));
    }
    if (type == 'hotel' || (end != null && end.isAfter(date))) {
      final out = (end != null && end.isAfter(date)) ? end : addDays(date, 1);
      stays.add(AiStay(name, date, out, placeKey: key));
      continue; // ubytování je v plánu jako od–do, ne jako položka dne
    }
    byDay.putIfAbsent(date, () => []).add(AiItem(title ?? name, minutes: _time(cell(c, 'time')), placeKey: key));
  }

  final dayList = byDay.keys.toList()..sort();
  final days = [
    for (final d in dayList) AiDay(d, byDay[d]!..sort((a, b) => (a.minutes ?? -1).compareTo(b.minutes ?? -1))),
  ];
  final dates = [...dayList, for (final s in stays) ...[s.checkIn, s.checkOut]]..sort();
  if (dates.isEmpty) return null;
  return AiTrip(
    name: tripName ?? tr('Cesta z AI'),
    start: dates.first,
    end: dates.last,
    countries: {for (final p in places.values) if (p.country != null) _country(p.country!)}.toList(),
    places: places.values.toList(),
    stays: stays,
    days: days,
  );
}


// ---------- volný itinerář (AI bez vzoru: Datum, Den, Oblast / nocleh, Program, Doprava, Poznámka) ----------

/// Začátky položek, které nejsou místem na mapu (přesuny, volno, část dne).
final _notPlace = RegExp(
  r'^(přejezd|přesun|přílet|přelet|odlet|návrat|cesta|let\b|transfer|arrival|arrive|departure|depart|travel|return|flight|'
  r'drive|train to|bus to|volno|volný|volná|odpočinek|relax|rest|free|ranní|večer|ráno|odpoledne|morning|evening|afternoon|'
  r'night|noc|lehký|rezervní|optional|nebo|or\b|check)',
  caseSensitive: false,
);

/// Program dne → jednotlivé položky (čárka, středník, „+“; čárky v závorkách se nedělí).
List<String> _splitProgram(String program) {
  final out = <String>[];
  final b = StringBuffer();
  var depth = 0;
  for (final ch in program.split('')) {
    if (ch == '(') depth++;
    if (ch == ')' && depth > 0) depth--;
    if (depth == 0 && (ch == ',' || ch == ';')) {
      out.add(b.toString());
      b.clear();
    } else {
      b.write(ch);
    }
  }
  out.add(b.toString());
  return [
    for (final x in out)
      if (x.trim().isNotEmpty) x.trim()
  ];
}

/// Název cesty z názvu souboru („Vietnam_itinerar_2026-12-05_2027-01-15.csv“ → „Vietnam itinerar“).
String? _nameFromFile(String? fileName) {
  if (fileName == null) return null;
  final n = fileName
      .replaceAll(RegExp(r'\.[A-Za-z0-9]+$'), '')
      .replaceAll(RegExp(r'\d{4}-\d{2}-\d{2}'), '')
      .replaceAll(RegExp(r'[_\-]+'), ' ')
      .trim();
  if (n.isEmpty) return null;
  return n[0].toUpperCase() + n.substring(1);
}

AiTrip? _parseFreeCsv(Iterable<String> rows, String sep, Map<String, int> idx, String? fileName) {
  String? cell(List<String> c, String k) {
    final i = idx[k];
    if (i == null || i >= c.length) return null;
    final v = c[i].trim();
    return v.isEmpty ? null : v;
  }

  final places = <String, AiPlace>{};
  final days = <AiDay>[];
  final stays = <AiStay>[];
  String? lastArea, prevArea;
  DateTime? areaFrom, lastDate;

  void closeStay() {
    if (lastArea != null && areaFrom != null && lastDate != null) {
      stays.add(AiStay(lastArea, areaFrom, addDays(lastDate, 1), placeKey: 'area|${lastArea.toLowerCase()}'));
    }
  }

  for (final r in rows) {
    if (r.trim().isEmpty) continue;
    final c = _csvLine(r, sep);
    final date = _date(cell(c, 'date'));
    if (date == null) continue;
    final area = cell(c, 'area');
    final program = cell(c, 'program');
    final transport = cell(c, 'transport');
    final note = cell(c, 'note');

    // stejný nocleh ve dnech po sobě = jedno ubytování od–do
    if (area != null && area != lastArea) {
      closeStay();
      lastArea = area;
      areaFrom = date;
      places.putIfAbsent('area|${area.toLowerCase()}',
          () => AiPlace(key: 'area|${area.toLowerCase()}', name: area, type: 'hotel', optional: true));
    }
    final moved = prevArea != null && area != null && area != prevArea; // den přesunu
    prevArea = area ?? prevArea;
    lastDate = date;

    final items = <AiItem>[];
    if (transport != null && (moved || (program ?? '').contains('→'))) {
      items.add(AiItem('🚌 $transport'));
    }
    for (final piece in _splitProgram(program ?? '')) {
      final isPlace = !_notPlace.hasMatch(piece) &&
          !piece.contains('→') &&
          piece.length <= 60 &&
          RegExp(r'\p{Lu}', unicode: true).hasMatch(piece);
      String? key;
      if (isPlace) {
        key = '${piece.toLowerCase()}|${(area ?? '').toLowerCase()}';
        places.putIfAbsent(key, () => AiPlace(key: key!, name: piece, city: area, type: 'attraction', optional: true));
      }
      items.add(AiItem(piece, placeKey: key));
    }
    if (note != null) items.add(AiItem('💡 $note'));
    days.add(AiDay(date, items));
  }
  closeStay();
  if (days.isEmpty) return null;
  final dates = [for (final d in days) d.date]..sort();
  return AiTrip(
    name: _nameFromFile(fileName) ?? tr('Cesta z AI'),
    start: dates.first,
    end: dates.last,
    places: places.values.toList(),
    stays: stays,
    days: days,
  );
}
