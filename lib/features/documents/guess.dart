const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
};

/// Najde v textu první datum (2027-01-20, 20.1.2027, 20 Jan 2027).
DateTime? guessDate(String text) {
  final found = <int, DateTime>{};

  for (final m in RegExp(r'(\d{4})-(\d{2})-(\d{2})').allMatches(text)) {
    final d = _make(m.group(1)!, m.group(2)!, m.group(3)!);
    if (d != null) found[m.start] = d;
  }
  for (final m in RegExp(r'(\d{1,2})[./](\d{1,2})[./](\d{4})').allMatches(text)) {
    final d = _make(m.group(3)!, m.group(2)!, m.group(1)!);
    if (d != null) found[m.start] = d;
  }
  final named = RegExp(
    r'(\d{1,2})\s*(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?,?\s*(\d{4})',
    caseSensitive: false,
  );
  for (final m in named.allMatches(text)) {
    final mon = _months[m.group(2)!.toLowerCase()];
    final d = _make(m.group(3)!, '$mon', m.group(1)!);
    if (d != null) found[m.start] = d;
  }
  for (final m in RegExp(r'(\d{4})\s*年\s*(\d{1,2})\s*月\s*(\d{1,2})\s*日').allMatches(text)) {
    final d = _make(m.group(1)!, m.group(2)!, m.group(3)!);
    if (d != null) found[m.start] = d;
  }
  if (found.isEmpty) return null;
  final first = found.keys.reduce((a, b) => a < b ? a : b);
  return found[first];
}

DateTime? _make(String y, String m, String d) {
  final yy = int.tryParse(y), mm = int.tryParse(m), dd = int.tryParse(d);
  if (yy == null || mm == null || dd == null) return null;
  if (yy < 2020 || yy > 2040 || mm < 1 || mm > 12 || dd < 1 || dd > 31) {
    return null;
  }
  return DateTime(yy, mm, dd);
}

/// První čas v textu jako minuty od půlnoci.
int? guessTime(String text) {
  final m = RegExp(r'\b([01]?\d|2[0-3]):([0-5]\d)\b').firstMatch(text);
  if (m != null) {
    return int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  }
  final jp = RegExp(r'([01]?\d|2[0-3])\s*時\s*([0-5]?\d)\s*分').firstMatch(text);
  if (jp == null) return null;
  return int.parse(jp.group(1)!) * 60 + int.parse(jp.group(2)!);
}

/// Číslo rezervace za slovy jako Booking / Reservation / PNR / Rezervace.
String? guessBookingRef(String text) {
  final m = RegExp(
    r'(?:booking|reservation|confirmation|pnr|rezervace|record locator)[^A-Za-z0-9]{0,15}([A-Z0-9]{5,10})',
    caseSensitive: false,
  ).firstMatch(text);
  return m?.group(1)?.toUpperCase();
}
