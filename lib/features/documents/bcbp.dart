/// Palubní lístek ve standardu IATA BCBP (QR / PDF417 / Aztec začínající „M1“).
class Bcbp {
  const Bcbp({
    required this.name,
    required this.pnr,
    required this.from,
    required this.to,
    required this.carrier,
    required this.flight,
    required this.julianDay,
    this.seat,
  });
  final String name;
  final String pnr;
  final String from;
  final String to;
  final String carrier;
  final String flight; // např. TG935
  final int julianDay; // den v roce, rok se v kódu nenachází
  final String? seat;
}

final _iata = RegExp(r'^[A-Z]{3}$');

Bcbp? parseBcbp(String s) => _parseStrict(s) ?? _parseLoose(s);

/// Tolerantní čtení pro kódy, kde jméno není doplněné mezerami na 20 znaků
/// (testovací nebo ručně vytvořené kódy).
Bcbp? _parseLoose(String s) {
  final m = RegExp(
    r'^M\d(.+?)\s+E([A-Z0-9]{6,7})\s*([A-Z]{3})([A-Z]{3})([A-Z0-9]{2})\s*(\d{1,5}[A-Z]?)\s*(\d{3})[A-Z]',
  ).firstMatch(s);
  if (m == null) return null;
  final julian = int.tryParse(m.group(7)!);
  if (julian == null || julian < 1 || julian > 366) return null;
  final carrier = m.group(5)!.trim();
  final number = m.group(6)!.replaceFirst(RegExp(r'^0+'), '');
  return Bcbp(
    name: m.group(1)!.trim(),
    pnr: m.group(2)!.trim(),
    from: m.group(3)!,
    to: m.group(4)!,
    carrier: carrier,
    flight: '$carrier$number',
    julianDay: julian,
  );
}

Bcbp? _parseStrict(String s) {
  if (s.length < 58 || s[0] != 'M') return null;
  final from = s.substring(30, 33);
  final to = s.substring(33, 36);
  if (!_iata.hasMatch(from) || !_iata.hasMatch(to)) return null;
  final julian = int.tryParse(s.substring(44, 47));
  if (julian == null || julian < 1 || julian > 366) return null;
  final carrier = s.substring(36, 39).trim();
  final number = s.substring(39, 44).trim().replaceFirst(RegExp(r'^0+'), '');
  return Bcbp(
    name: s.substring(2, 22).trim(),
    pnr: s.substring(23, 30).trim(),
    from: from,
    to: to,
    carrier: carrier,
    flight: '$carrier$number',
    julianDay: julian,
    seat: s.length >= 52
        ? s.substring(48, 52).trim().replaceFirst(RegExp(r'^0+'), '')
        : null,
  );
}

/// Z čísla dne v roce udělá datum; rok vybere tak, aby bylo nejblíž [ref].
DateTime dateFromJulian(int julian, DateTime ref) {
  DateTime? best;
  for (final y in [ref.year - 1, ref.year, ref.year + 1]) {
    final d = DateTime(y, 1, julian);
    if (best == null ||
        d.difference(ref).abs() < best.difference(ref).abs()) {
      best = d;
    }
  }
  return best!;
}
