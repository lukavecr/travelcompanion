import '../../l10n/tr.dart';
import 'scan_service.dart';

/// Doklad vytvořený z textu (e-mail s rezervací) – nemá obrázek.
const emailDocPath = 'text:';

final _mapsLink = RegExp(r'maps\.app\.goo\.gl|goo\.gl/maps|google\.[a-z.]+/maps|maps\.google\.');

final _flightWord = RegExp(
    r'\b(?:flight|flights|let|lety|letu|flug|vuelo|vol|boarding|departure|odlet|abflug|salida|airline|aerolínea|airport|letiště|flughafen|aeropuerto)\b',
    caseSensitive: false);
final _hotelWord = RegExp(
    r'check-?\s?in|check-?\s?out|booking\.com|airbnb|agoda|hostel|hotel|ryokan|apartm|accommodation|ubytování|unterkunft|alojamiento|guesthouse|resort',
    caseSensitive: false);
final _bookingWord = RegExp(
    r'booking|reservation|confirmation|itinerary|e-?ticket|rezervac|potvrzení|jízdenk|letenk|buchung|bestätigung|reserva|confirmación|billete|ticket|pnr',
    caseSensitive: false);

/// Rozhodne, jestli sdílený text vypadá jako rezervace (a ne jako odkaz z Map).
bool looksLikeBooking(String text) {
  if (_mapsLink.hasMatch(text) && text.length < 400) return false;
  if (text.trim().length < 80) return false;
  if (findDates(text).isEmpty) return false;
  return _bookingWord.hasMatch(text) || _flightNumbers(text).isNotEmpty || _hotelWord.hasMatch(text);
}

// ---------- data ----------

class FoundDate {
  const FoundDate(this.pos, this.end, this.date);
  final int pos;
  final int end;
  final DateTime date;
}

const _monthNames = <String, int>{
  // en
  'jan': 1, 'january': 1, 'feb': 2, 'february': 2, 'mar': 3, 'march': 3, 'apr': 4, 'april': 4,
  'may': 5, 'jun': 6, 'june': 6, 'jul': 7, 'july': 7, 'aug': 8, 'august': 8, 'sep': 9, 'sept': 9,
  'september': 9, 'oct': 10, 'october': 10, 'nov': 11, 'november': 11, 'dec': 12, 'december': 12,
  // cs (2. pád i 1. pád)
  'ledna': 1, 'leden': 1, 'února': 2, 'únor': 2, 'března': 3, 'březen': 3, 'dubna': 4, 'duben': 4,
  'května': 5, 'květen': 5, 'června': 6, 'červen': 6, 'července': 7, 'červenec': 7, 'srpna': 8,
  'srpen': 8, 'září': 9, 'října': 10, 'říjen': 10, 'listopadu': 11, 'listopad': 11,
  'prosince': 12, 'prosinec': 12,
  // de
  'januar': 1, 'jänner': 1, 'februar': 2, 'märz': 3, 'mai': 5, 'juni': 6, 'juli': 7,
  'oktober': 10, 'dezember': 12, 'okt': 10, 'dez': 12, 'mär': 3,
  // es
  'enero': 1, 'febrero': 2, 'marzo': 3, 'abril': 4, 'mayo': 5, 'junio': 6, 'julio': 7,
  'agosto': 8, 'septiembre': 9, 'setiembre': 9, 'octubre': 10, 'noviembre': 11, 'diciembre': 12,
  'ene': 1, 'abr': 4, 'ago': 8, 'dic': 12,
};

final _monthAlt = (_monthNames.keys.toList()..sort((a, b) => b.length.compareTo(a.length)))
    .map(RegExp.escape)
    .join('|');

DateTime? _mk(int y, int m, int d) {
  if (y < 2020 || y > 2040 || m < 1 || m > 12 || d < 1 || d > 31) return null;
  final r = DateTime(y, m, d);
  return r.month == m ? r : null;
}

int? _mon(String s) => _monthNames[s.toLowerCase().replaceAll('.', '')];

/// Všechna data v textu (ISO, 12.11.2026, 12. 11. 2026, 12 Nov 2026, Nov 12, 2026,
/// 12. listopadu 2026, 12 de noviembre de 2026, 2026年11月12日), seřazená podle pozice.
List<FoundDate> findDates(String text) {
  final out = <FoundDate>[];
  void add(Match m, DateTime? d) {
    if (d == null) return;
    if (out.any((o) => m.start < o.end && o.pos < m.end)) return; // překryv
    out.add(FoundDate(m.start, m.end, d));
  }

  for (final m in RegExp(r'\b(\d{4})-(\d{2})-(\d{2})').allMatches(text)) {
    add(m, _mk(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!)));
  }
  for (final m in RegExp(r'(\d{4})\s*年\s*(\d{1,2})\s*月\s*(\d{1,2})\s*日').allMatches(text)) {
    add(m, _mk(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!)));
  }
  for (final m in RegExp(r'\b(\d{1,2})\s*[./]\s*(\d{1,2})\s*[./]\s*(\d{4})\b').allMatches(text)) {
    add(m, _mk(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!)));
  }
  final dayMonth = RegExp('\\b(\\d{1,2})\\.?\\s*(?:de\\s+)?($_monthAlt)\\.?,?\\s*(?:de\\s+)?(\\d{4})\\b',
      caseSensitive: false, unicode: true);
  for (final m in dayMonth.allMatches(text)) {
    final mon = _mon(m.group(2)!);
    if (mon != null) add(m, _mk(int.parse(m.group(3)!), mon, int.parse(m.group(1)!)));
  }
  final monthDay = RegExp('\\b($_monthAlt)\\.?\\s+(\\d{1,2})(?:st|nd|rd|th)?,?\\s+(\\d{4})\\b',
      caseSensitive: false, unicode: true);
  for (final m in monthDay.allMatches(text)) {
    final mon = _mon(m.group(1)!);
    if (mon != null) add(m, _mk(int.parse(m.group(3)!), mon, int.parse(m.group(2)!)));
  }
  out.sort((a, b) => a.pos.compareTo(b.pos));
  return out;
}

/// Časy v textu jako (pozice, minuty od půlnoci); zvládne i 10:35 PM.
List<(int, int)> findTimes(String text) {
  final out = <(int, int)>[];
  for (final m in RegExp(r'\b([01]?\d|2[0-3])[:.]([0-5]\d)\s*([AaPp]\.?[Mm]\.?)?(?![\d.])').allMatches(text)) {
    // 12.11.2026 – tečka následovaná číslem je datum, ne čas
    final before = m.start > 0 ? text[m.start - 1] : ' ';
    if (RegExp(r'[\d.]').hasMatch(before)) continue;
    var h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)?.toLowerCase();
    if (ap != null) {
      if (h > 12) continue;
      if (ap.startsWith('p') && h < 12) h += 12;
      if (ap.startsWith('a') && h == 12) h = 0;
    } else if (m.group(0)!.contains('.')) {
      continue; // 10.35 bez AM/PM bývá spíš částka
    }
    out.add((m.start, h * 60 + min));
  }
  return out;
}

// ---------- jednotlivé údaje ----------

final _flightNo = RegExp(r'\b([A-Z][A-Z0-9]|[0-9][A-Z])\s?(\d{2,4})\b');
const _notAirline = {'ID', 'NO', 'NR', 'PO', 'TO', 'AT', 'IN', 'ON', 'OF', 'OR', 'PS', 'PM', 'AM', 'TV', 'UK'};

List<(int, String)> _flightNumbers(String text) {
  final out = <(int, String)>[];
  for (final m in _flightNo.allMatches(text)) {
    final code = m.group(1)!;
    final num = m.group(2)!;
    if (_notAirline.contains(code)) continue;
    if (num.length == 4 && (num.startsWith('20') || num.startsWith('19'))) continue; // rok
    // musí stát u slova „let/flight“ nebo vedle kódů letišť
    final around = text.substring((m.start - 60).clamp(0, text.length), (m.end + 80).clamp(0, text.length));
    if (!_flightWord.hasMatch(around) && _airportPairs(around).isEmpty) continue;
    final f = '$code$num';
    if (out.any((o) => o.$2 == f)) continue;
    out.add((m.start, f));
  }
  return out;
}

final _iataParen = RegExp(r'\(([A-Z]{3})\)');
final _iataArrow = RegExp(r'\b([A-Z]{3})\s*(?:-|–|—|→|->|>|to|až|nach|a)\s*([A-Z]{3})\b');
const _notIata = {'EUR', 'USD', 'CZK', 'JPY', 'GBP', 'THB', 'VND', 'PLN', 'CHF', 'AUD', 'CAD', 'PIN', 'VAT', 'DPH', 'TAX', 'FEE', 'THE', 'AND'};

List<(int, String, String)> _airportPairs(String text) {
  final out = <(int, String, String)>[];
  for (final m in _iataArrow.allMatches(text)) {
    final a = m.group(1)!, b = m.group(2)!;
    if (a != b && !_notIata.contains(a) && !_notIata.contains(b)) out.add((m.start, a, b));
  }
  final paren = _iataParen.allMatches(text).where((m) => !_notIata.contains(m.group(1))).toList();
  for (var i = 0; i + 1 < paren.length; i += 2) {
    final a = paren[i].group(1)!, b = paren[i + 1].group(1)!;
    if (a != b && !out.any((o) => o.$2 == a && o.$3 == b)) out.add((paren[i].start, a, b));
  }
  out.sort((x, y) => x.$1.compareTo(y.$1));
  return out;
}

final _refWord = RegExp(
  r'(?:booking|reservation|confirmation|reference|order|record locator|pnr|rezervac\w*|potvrzení|kód|buchungs\w*|bestätigungs\w*|auftrags\w*|localizador|código|reserva)',
  caseSensitive: false,
);
final _refCode = RegExp(r'(?<![A-Za-z0-9])([A-Z0-9][A-Z0-9.\-]{4,15}[A-Z0-9])(?![A-Za-z0-9])');

/// Číslo rezervace: první kód (velká písmena / číslice) těsně za slovem „booking“, „rezervace“…
String? _ref(String text) {
  for (final w in _refWord.allMatches(text)) {
    final tail = text.substring(w.end, (w.end + 40).clamp(0, text.length)).split('\n').first;
    for (final m in _refCode.allMatches(tail)) {
      final v = m.group(1)!;
      final digits = RegExp(r'\d').hasMatch(v);
      if (!digits && (v.length < 5 || v.length > 8)) continue;
      return v;
    }
  }
  return null;
}

final _nameRe = RegExp(
  r'(?:passenger|traveller|traveler|guest name|guest|lead guest|name|cestující|jméno hosta|jméno|host|reisender|fluggast|gast|pasajero|huésped|nombre)\s*(?:name)?\s*[:：]\s*([^\n\r,;]{3,40})',
  caseSensitive: false,
);

String? _name(String text) => _nameRe.firstMatch(text)?.group(1)?.trim();

final _checkIn = RegExp(r'check-?\s?in|příjezd|arrival|anreise|llegada|entrada', caseSensitive: false);
final _checkOut = RegExp(r'check-?\s?out|odjezd|departure|abreise|salida', caseSensitive: false);
final _departWord = RegExp(r'departure|depart|odlet|odjezd|abflug|abfahrt|salida|outbound|tam', caseSensitive: false);

/// První datum za slovem (do 80 znaků).
FoundDate? _dateAfter(String text, RegExp word, List<FoundDate> dates) {
  for (final w in word.allMatches(text)) {
    for (final d in dates) {
      if (d.pos >= w.end && d.pos - w.end < 80) return d;
    }
  }
  return null;
}

int? _timeNear(List<(int, int)> times, int pos, {int maxGap = 120}) {
  for (final t in times) {
    if (t.$1 >= pos && t.$1 - pos <= maxGap) return t.$2;
  }
  return null;
}

final _hotelNameRe = RegExp(
  r'(?:booking (?:is )?confirmed (?:at|in)|your (?:stay|reservation|booking) at|reservation at|staying at|booked at|rezervace (?:v|ve)|ubytování (?:v|ve)|buchung (?:im|in|bei)|reserva en)\s+(?:the\s+)?([^\n\r!.]{3,60}?)(?:\s+(?:is|je|ist|está)\s+(?:confirmed|potvrzen\w*|bestätigt|confirmad\w*)|[!.\n\r]|$)',
  caseSensitive: false,
);
final _propertyWord = RegExp(r'\b(?:hotel|hostel|inn|resort|ryokan|apartments?|apartmány?|guest ?house|lodge|villa|suites?|penzion)\b', caseSensitive: false);

String? _hotelName(String text) {
  final m = _hotelNameRe.firstMatch(text);
  if (m != null) return m.group(1)!.trim();
  for (final line in text.split(RegExp(r'[\r\n]+'))) {
    final l = line.trim();
    if (l.length < 4 || l.length > 60) continue;
    if (_propertyWord.hasMatch(l) && !_checkIn.hasMatch(l) && !_checkOut.hasMatch(l) && !l.contains(':')) {
      return l;
    }
  }
  return null;
}

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _guessType(String text) {
  final s = text.toLowerCase();
  bool any(List<String> k) => k.any(s.contains);
  if (any(['flixbus', 'bus ticket', 'autobus', 'regiojet bus', 'fernbus', 'autobús'])) return 'bus';
  if (any(['ferry', 'trajekt', 'fähre', 'ferri'])) return 'ferry';
  if (any(['train', 'vlak', 'zug', 'tren', 'rail', 'shinkansen', 'čd ', 'regiojet', 'jízdenk', 'bahn'])) return 'train';
  if (any(['admission', 'entrance', 'tour', 'vstupenk', 'eintritt', 'entrada al', 'museum', 'tickets for'])) return 'ticket';
  if (any(['insurance', 'pojištění', 'versicherung', 'seguro'])) return 'insurance';
  return 'other';
}

/// Z textu e-mailu s rezervací vytáhne doklady (lety po segmentech, ubytování, jízdenky…).
/// Výsledek jde rovnou do formuláře nového dokladu (bez obrázku).
List<ScanResult> parseBookingText(String raw) {
  final text = raw.replaceAll(' ', ' ').replaceAll('\r', '');
  final dates = findDates(text);
  final times = findTimes(text);
  final ref = _ref(text);
  final name = _name(text);
  final out = <ScanResult>[];

  // --- lety ---
  final flights = _flightNumbers(text);
  if (flights.isNotEmpty && (_flightWord.hasMatch(text) || _airportPairs(text).isNotEmpty)) {
    final leads = dates.isEmpty || flights.first.$1 < dates.first.pos;
    for (var i = 0; i < flights.length; i++) {
      final (pos, number) = flights[i];
      // číslo letu stojí buď na začátku bloku (před datem), nebo na jeho konci
      final lo = i == 0 ? 0 : (leads ? pos : flights[i - 1].$1 + 6);
      final hi = i == flights.length - 1 ? text.length : (leads ? flights[i + 1].$1 : pos + 6);
      final win = text.substring(lo, hi);
      final f = <String, String>{'type': 'flight', 'flight': number, 'carrier': number.substring(0, 2)};
      final pairs = _airportPairs(win);
      if (pairs.isNotEmpty) {
        f['from'] = pairs.first.$2;
        f['to'] = pairs.first.$3;
      }
      final wd = dates.where((d) => d.pos >= lo && d.pos < hi).toList();
      final dep = _dateAfter(win, _departWord, wd.map((d) => FoundDate(d.pos - lo, d.end - lo, d.date)).toList());
      final d = dep != null ? FoundDate(dep.pos + lo, dep.end + lo, dep.date) : (wd.isNotEmpty ? wd.first : null);
      if (d != null) {
        f['date'] = _ymd(d.date);
        final t = _timeNear(times, d.end) ?? _timeNear(times.where((t) => t.$1 >= lo && t.$1 < hi).toList(), lo, maxGap: hi - lo);
        if (t != null) f['time'] = '$t';
      }
      f['title'] = f['from'] != null
          ? tr('Let {flight} {from} → {to}', {'flight': number, 'from': f['from'], 'to': f['to']})
          : tr('Let {flight}', {'flight': number});
      if (ref != null) f['ref'] = ref;
      if (name != null) f['name'] = name;
      out.add(ScanResult(emailDocPath, const [], text, f));
    }
    return out;
  }

  // --- ubytování ---
  final inD = _dateAfter(text, _checkIn, dates);
  final outD = _dateAfter(text, _checkOut, dates.where((d) => inD == null || d.pos != inD.pos).toList());
  if (_hotelWord.hasMatch(text) && inD != null) {
    final f = <String, String>{'type': 'hotel', 'date': _ymd(inD.date)};
    if (outD != null && outD.date.isAfter(inD.date)) f['endDate'] = _ymd(outD.date);
    final t = _timeNear(times, inD.end, maxGap: 60);
    if (t != null) f['time'] = '$t';
    final h = _hotelName(text);
    if (h != null) f['title'] = h;
    if (ref != null) f['ref'] = ref;
    if (name != null) f['name'] = name;
    out.add(ScanResult(emailDocPath, const [], text, f));
    return out;
  }

  // --- ostatní (vlak, bus, vstupenka…) ---
  final f = <String, String>{'type': _guessType(text)};
  final pairs = _airportPairs(text);
  if (pairs.isNotEmpty) {
    f['from'] = pairs.first.$2;
    f['to'] = pairs.first.$3;
  }
  final d = _dateAfter(text, _departWord, dates) ?? (dates.isNotEmpty ? dates.first : null);
  if (d != null) {
    f['date'] = _ymd(d.date);
    final t = _timeNear(times, d.end);
    if (t != null) f['time'] = '$t';
  }
  if (ref != null) f['ref'] = ref;
  if (name != null) f['name'] = name;
  final firstLine = text.split('\n').map((l) => l.trim()).firstWhere(
      (l) => l.length >= 4 && l.length <= 60 && !l.contains('http'),
      orElse: () => '');
  if (firstLine.isNotEmpty) f['title'] = firstLine;
  out.add(ScanResult(emailDocPath, const [], text, f));
  return out;
}
