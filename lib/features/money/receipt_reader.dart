import 'dart:math' as math;

import '../../core/country_info.dart';
import '../../core/format.dart';
import '../documents/field_extractor.dart';
import '../documents/guess.dart';
import '../documents/scan_service.dart';

class ReceiptGuess {
  const ReceiptGuess({
    required this.path,
    required this.text,
    this.amount,
    this.currency,
    this.date,
    this.category,
    this.merchant,
    this.country,
  });
  final String path;
  final String text;
  final double? amount;
  final String? currency;
  final DateTime? date;
  final String? category;
  final String? merchant;
  final String? country;
}

Future<ReceiptGuess> readReceipt(String path) async {
  final ocr = await runOcr(path);
  final text = ocr.text;
  final cur = guessCurrency(text);
  return ReceiptGuess(
    path: path,
    text: text,
    // nejdřív podle polohy „Celkem → číslo vpravo“, jinak z textu
    amount: guessTotalFromLines(ocr.lines) ?? guessAmount(text),
    currency: cur,
    date: guessDate(text),
    category: guessCategory(text),
    merchant: guessMerchant(ocr.lines),
    country: guessCountry(text, currency: cur),
  );
}

String? guessCurrency(String text) {
  final code = RegExp(
    r'\b(CZK|EUR|USD|THB|JPY|NZD|MXN|GBP|IDR|MYR|VND|PHP|SGD|AUD|CAD|CHF|PLN|HUF|KRW|INR)\b',
  ).firstMatch(text.toUpperCase());
  if (code != null) return code.group(1);
  if (text.contains('€')) return 'EUR';
  if (text.contains('円') || hasKana(text)) return 'JPY';
  if (text.contains('฿') ||
      hasThai(text) ||
      RegExp(r'\bbaht\b', caseSensitive: false).hasMatch(text)) {
    return 'THB';
  }
  if (text.contains('₫') || RegExp(r'\bdong\b|\bđồng\b', caseSensitive: false).hasMatch(text)) {
    return 'VND';
  }
  if (RegExp(r'Kč|\bKc\b', caseSensitive: false).hasMatch(text)) return 'CZK';
  if (text.contains('¥') || text.contains('￥')) return 'JPY';
  if (text.contains('\$')) return 'USD';
  return null;
}

/// Odhad celkové částky. Nejdřív čísla u značky ¥ / 円, pak největší číslo
/// na řádcích se slovy Total, Celkem, 合計; jinak největší číslo na účtence.
double? guessAmount(String text) {
  final yen = RegExp(r'(?:[¥￥]|\\)\s*([\d,]+)|([\d,]+)\s*円');
  final yenValues = <double>[];
  for (final m in yen.allMatches(text)) {
    final v = double.tryParse((m.group(1) ?? m.group(2) ?? '').replaceAll(',', ''));
    if (v != null && v > 0 && v < 10000000) yenValues.add(v);
  }
  if (yenValues.isNotEmpty) return yenValues.reduce(math.max);

  final numRe = RegExp(r'\d{1,3}(?:[ ,.]\d{3})+(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?');
  final keyword = RegExp(
    r'total|celkem|suma|součet|k úhradě|amount due|to pay|gesamt|balance|合計|お会計',
    caseSensitive: false,
  );
  double? fromKeyword;
  double? biggest;
  var pending = false;

  for (final line in text.split('\n')) {
    final nums = numRe
        .allMatches(line)
        .map((m) => parseAmount(m.group(0)!, ocr: true))
        .whereType<double>()
        .where((v) => v > 0 && v < 10000000)
        .toList();
    final hasKeyword = keyword.hasMatch(line) && !_notTotal.hasMatch(line);
    if (nums.isEmpty) {
      pending = hasKeyword;
      continue;
    }
    final lineMax = nums.reduce(math.max);
    biggest = biggest == null ? lineMax : math.max(biggest, lineMax);
    if (hasKeyword || pending) {
      fromKeyword = fromKeyword == null ? lineMax : math.max(fromKeyword, lineMax);
    }
    pending = false;
  }
  return fromKeyword ?? biggest;
}

/// Kategorie podle slov na účtence (Universal Studios -> atrakce).
String? guessCategory(String text) {
  final s = text.toLowerCase();
  bool any(List<String> k) => k.any(s.contains);
  if (any(['universal', 'studios', 'museum', 'muzeum', 'temple', 'shrine', 'zoo',
      'aquarium', 'admission', 'entrance', 'vstupenka', 'tour', 'výlet', '入場',
      '神社', '拝観', 'theme park', 'amusement'])) {
    return 'attractions';
  }
  if (any(['hotel', 'hostel', 'resort', 'ubytování', 'guest house', '宿泊'])) {
    return 'lodging';
  }
  if (any(['taxi', 'grab', 'train', 'metro', 'subway', 'airline', 'airways',
      'ferry', 'suica', 'icoca', '電車', '新幹線', 'bus ticket'])) {
    return 'transport';
  }
  if (any(['restaurant', 'cafe', 'coffee', 'ramen', 'sushi', 'pizza', 'burger',
      'bistro', 'noodle', 'レストラン', 'food', 'bar & grill'])) {
    return 'food';
  }
  if (any(['market', 'mall', 'supermarket', 'store', 'shop', '7-eleven', 'lawson',
      'familymart', 'tesco', 'souvenir'])) {
    return 'shopping';
  }
  return null;
}

// ---------- celková částka podle polohy na fotce ----------

/// Silné popisky konečné částky (k zaplacení) – mají přednost.
final _totalStrong = RegExp(
  r'k\s*úhrad|k\s*uhrad|celkem\s*k|amount\s*due|grand\s*total|total\s*due|to\s*pay|zu\s*zahlen|total\s*a\s*pagar|'
  r'importe\s*total|tổng\s*cộng|tong\s*cong|合計|お会計|ご請求|ยอดสุทธิ|รวมทั้งสิ้น',
  caseSensitive: false,
);

/// Obecné popisky celkové částky.
final _totalWord = RegExp(
  r'total|celkem|celkov|suma|součet|soucet|summe|gesamt|betrag|importe|tổng|tong|รวม|итого|razem|osszesen|összesen|totaal',
  caseSensitive: false,
);

/// Řádky, které celkovou částkou nejsou (mezisoučet, DPH, přijatá hotovost, vráceno…).
final _notTotal = RegExp(
  r'sub\s*-?\s*total|subtotal|mezisou|dph|vat\b|tax|daň|dan\b|základ|zaklad|sazb|mwst|ust\b|netto|'
  r'zaokrouhl|rounding|change|vráceno|vraceno|vrátit|přijato|prijato|hotovost|cash|tendered|received|'
  r'tip\b|spropitn|items|položek|polozek|počet|pocet|qty|\bks\b|'
  r'小計|お預|お釣|釣銭|税|ภาษี|เงินทอน|tiền\s*thối|tien\s*thoi|vat\s*\d',
  caseSensitive: false,
);

final _amountRe = RegExp(r'\d{1,3}(?:[ ,.]\d{3})+(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?');

List<double> _amountsIn(String s) => _amountRe
    .allMatches(s)
    // datum (26.10.2026) ani čas (14:30) nejsou částky
    .where((m) {
      final after = m.end < s.length ? s[m.end] : ' ';
      final before = m.start > 0 ? s[m.start - 1] : ' ';
      return after != ':' && before != ':' && !(after == '.' && m.end + 1 < s.length && RegExp(r'\d').hasMatch(s[m.end + 1]));
    })
    .map((m) => parseAmount(m.group(0)!, ocr: true))
    .whereType<double>()
    .where((v) => v > 0 && v < 10000000)
    .toList();

/// Celková částka z řádků OCR podle polohy: popisek „Celkem / Total / K úhradě / 合計“
/// a číslo vpravo na stejném řádku (nebo hned pod ním). null = popisek nenalezen.
double? guessTotalFromLines(List<OcrLine> lines) {
  double? best;
  var bestScore = -1;
  for (final l in lines) {
    final strong = _totalStrong.firstMatch(l.text);
    final word = strong ?? _totalWord.firstMatch(l.text);
    if (word == null || _notTotal.hasMatch(l.text)) continue;
    final score = strong != null ? 2 : 1;

    // číslo za popiskem na stejném řádku OCR
    var nums = _amountsIn(l.text.substring(word.end));
    if (nums.isEmpty) {
      // vpravo na stejné výšce (účtenky mají popisky vlevo a částky vpravo)
      final r = l.rect;
      final right = lines
          .where((o) => !identical(o, l) && o.rect.left >= r.left + r.width * 0.5)
          .where((o) => (o.rect.center.dy - r.center.dy).abs() < math.max(r.height, o.rect.height) * 0.6)
          .where((o) => !_notTotal.hasMatch(o.text))
          .toList()
        ..sort((a, b) => a.rect.left.compareTo(b.rect.left));
      for (final o in right) {
        nums = _amountsIn(o.text);
        if (nums.isNotEmpty) break;
      }
    }
    if (nums.isEmpty) {
      // těsně pod popiskem
      final r = l.rect;
      final below = lines
          .where((o) => !identical(o, l) && o.rect.top >= r.bottom - 4 && o.rect.top - r.bottom < r.height * 1.8)
          .where((o) => math.min(r.right, o.rect.right) - math.max(r.left, o.rect.left) > -r.width * 0.5)
          .toList()
        ..sort((a, b) => a.rect.top.compareTo(b.rect.top));
      for (final o in below) {
        nums = _amountsIn(o.text);
        if (nums.isNotEmpty) break;
      }
    }
    if (nums.isEmpty) continue;
    final v = nums.reduce(math.max);
    // silnější popisek vyhrává; při stejném popisku větší částka (celkem > položka)
    if (score > bestScore || (score == bestScore && v > best!)) {
      best = v;
      bestScore = score;
    }
  }
  return best;
}
