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
    amount: guessAmount(text),
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
    final hasKeyword = keyword.hasMatch(line);
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
