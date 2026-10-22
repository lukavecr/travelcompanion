import 'app_settings.dart';

const _weekdays = ['Po', 'Út', 'St', 'Čt', 'Pá', 'So', 'Ne'];

String _pad2(int n) => n.toString().padLeft(2, '0');

/// Datum podle nastavení (Personalizace → Formát data).
String fmtDate(DateTime d) => switch (AppSettings.instance.dateFormat) {
      'dmy_slash' => '${_pad2(d.day)}/${_pad2(d.month)}/${d.year}',
      'mdy' => '${_pad2(d.month)}/${_pad2(d.day)}/${d.year}',
      'iso' => '${d.year}-${_pad2(d.month)}-${_pad2(d.day)}',
      _ => '${d.day}. ${d.month}. ${d.year}',
    };

/// Den bez roku: „Po 23. 10.“
String fmtDay(DateTime d) {
  final date = switch (AppSettings.instance.dateFormat) {
    'dmy_slash' => '${_pad2(d.day)}/${_pad2(d.month)}',
    'mdy' => '${_pad2(d.month)}/${_pad2(d.day)}',
    'iso' => '${_pad2(d.month)}-${_pad2(d.day)}',
    _ => '${d.day}. ${d.month}.',
  };
  return '${_weekdays[d.weekday - 1]} $date';
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// 570 -> "09:30" (nebo "9:30 AM" při 12h formátu)
String fmtTime(int minutes) {
  final h = (minutes ~/ 60) % 24, m = minutes % 60;
  if (AppSettings.instance.use24h) return '${_pad2(h)}:${_pad2(m)}';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:${_pad2(m)} ${h < 12 ? 'AM' : 'PM'}';
}

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
