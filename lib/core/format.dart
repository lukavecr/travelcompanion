const _weekdays = ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'];

String fmtDate(DateTime d) => '${d.day}. ${d.month}. ${d.year}';

String fmtDay(DateTime d) => '${_weekdays[d.weekday - 1]} ${d.day}. ${d.month}.';

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 570 -> "09:30"
String fmtTime(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

/// 20 -> "20 min", 60 -> "1 h", 90 -> "1 h 30 min"
String fmtLead(int minutes) {
  if (minutes < 60) return '$minutes min';
  if (minutes % 60 == 0) return '${minutes ~/ 60} h';
  return '${minutes ~/ 60} h ${minutes % 60} min';
}

/// 12650.4 -> "12 650" (pevná mezera jako oddělovač tisíců)
String fmtMoney(double v, [int decimals = 0]) {
  final neg = v < 0;
  final parts = v.abs().toStringAsFixed(decimals).split('.');
  final digits = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('\u00A0');
    buf.write(digits[i]);
  }
  final dec = decimals > 0 ? ',${parts[1]}' : '';
  return '${neg ? '-' : ''}$buf$dec';
}

/// Převede zadaný nebo přečtený text na číslo. "12,5" i "1 234.50".
/// U přečtené účtenky ([ocr]) se jediný oddělovač před třemi číslicemi
/// bere jako oddělovač tisíců.
double? parseAmount(String input, {bool ocr = false}) {
  var s = input.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (s.isEmpty) return null;
  final lc = s.lastIndexOf(',');
  final ld = s.lastIndexOf('.');
  if (lc >= 0 && ld >= 0) {
    final dec = lc > ld ? ',' : '.';
    final th = dec == ',' ? '.' : ',';
    s = s.replaceAll(th, '').replaceAll(dec, '.');
  } else if (lc >= 0 || ld >= 0) {
    final c = lc >= 0 ? ',' : '.';
    final idx = lc >= 0 ? lc : ld;
    final count = c.allMatches(s).length;
    final after = s.length - idx - 1;
    if (count > 1 || (ocr && after == 3)) {
      s = s.replaceAll(c, '');
    } else {
      s = s.replaceAll(c, '.');
    }
  }
  return double.tryParse(s);
}
