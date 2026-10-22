import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'guess.dart';

class OcrLine {
  const OcrLine(this.text, this.rect);
  final String text;
  final Rect rect;
}

class _Key {
  const _Key(this.key, this.latin, this.jp);
  final String key;
  final RegExp latin;
  final RegExp jp;
}

final _keys = <_Key>[
  _Key(
    'ref',
    RegExp(
        r'\b(?:booking|reservation|confirmation|order|reference|pnr|rezervace)(?:\s*(?:no\.?|number|code|id|ref\.?|číslo|kód))?',
        caseSensitive: false),
    RegExp(r'予約番号|確認番号|注文番号|予約'),
  ),
  _Key(
    'name',
    RegExp(
        r'\b(?:customer|guest|passenger|traveller|traveler|jméno|cestující|name)\b(?:\s*name)?',
        caseSensitive: false),
    RegExp(r'氏名|お名前|ご利用者|乗客'),
  ),
  _Key(
    'date',
    RegExp(r'\b(?:date|datum|departure|check-?in|travel\s+date|activity\s+date)\b',
        caseSensitive: false),
    RegExp(r'ご利用日|乗車日|出発日|日付'),
  ),
  _Key(
    'time',
    RegExp(r'\b(?:time|pick-?up|čas|odjezd)\b', caseSensitive: false),
    RegExp(r'出発時刻|時刻|時間'),
  ),
  _Key(
    'seat',
    RegExp(r'\b(?:seat|sedadlo)\b', caseSensitive: false),
    RegExp(r'座席番号|座席'),
  ),
  _Key(
    'gate',
    RegExp(r'\b(?:gate|platform|track|nástupiště)\b', caseSensitive: false),
    RegExp(r'搭乗口|番線|ホーム'),
  ),
];

/// Páruje popisky (Booking, Customer, Seat...) s hodnotami podle polohy na
/// fotce: hodnota bývá za popiskem na stejném řádku nebo těsně pod ním.
Map<String, String> extractFields(List<OcrLine> lines) {
  final out = <String, String>{};
  for (final k in _keys) {
    for (final l in lines) {
      final m = k.latin.firstMatch(l.text) ?? k.jp.firstMatch(l.text);
      if (m == null) continue;
      final raw = _valueFor(l, m.end, lines);
      if (raw == null) continue;
      final v = _clean(k.key, raw);
      if (v != null) {
        out[k.key] = v;
        break;
      }
    }
  }
  return out;
}

String? _valueFor(OcrLine l, int labelEnd, List<OcrLine> all) {
  final rest = l.text
      .substring(labelEnd)
      .replaceFirst(RegExp(r'^[\s:：\-–.#]+'), '')
      .trim();
  if (rest.length >= 2) return rest;

  final r = l.rect;

  // vpravo na stejném řádku
  OcrLine? best;
  var bestScore = double.infinity;
  for (final o in all) {
    if (identical(o, l)) continue;
    final q = o.rect;
    final h = math.max(r.height, q.height);
    final sameRow = (q.center.dy - r.center.dy).abs() < h * 0.7 && q.left >= r.right - 4;
    if (sameRow && q.left - r.right < bestScore) {
      best = o;
      bestScore = q.left - r.right;
    }
  }
  if (best != null) return best.text;

  // těsně pod popiskem
  bestScore = double.infinity;
  for (final o in all) {
    if (identical(o, l)) continue;
    final q = o.rect;
    final overlap = math.min(r.right, q.right) - math.max(r.left, q.left);
    final gap = q.top - r.bottom;
    if (overlap > 0 && gap > -4 && gap < r.height * 3 && gap < bestScore) {
      best = o;
      bestScore = gap;
    }
  }
  return best?.text;
}

String? _clean(String key, String value) {
  final v = value.trim();
  switch (key) {
    case 'ref':
      final m = RegExp(r'[A-Z0-9][A-Z0-9\-]{4,}').firstMatch(v.toUpperCase());
      return m?.group(0);
    case 'name':
      if (!RegExp(r'[A-Za-z\u00c0-\u024f\u3040-\u9fff]').hasMatch(v)) return null;
      if (v.length < 3 || v.length > 40) return null;
      return v;
    case 'date':
      final d = guessDate(v);
      if (d == null) return null;
      return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    case 'time':
      final t = guessTime(v);
      return t?.toString();
    case 'seat':
      final m = RegExp(r'\b\d{1,3}[A-Z]?\b|\b[A-Z]\d{1,3}\b').firstMatch(v.toUpperCase());
      return m?.group(0);
    case 'gate':
      final m = RegExp(r'\b[A-Z]?\d{1,3}[A-Z]?\b').firstMatch(v.toUpperCase());
      if (m != null) return m.group(0);
      return v.length <= 10 ? v : null;
  }
  return null;
}

/// Název obchodu / místa: první smysluplný řádek v horní části dokladu.
String? guessMerchant(List<OcrLine> lines) {
  final skip = RegExp(
      r'^[\d\s:./\-,]+$|receipt|invoice|tax|ticket no|www\.|http|領収|レシート',
      caseSensitive: false);
  for (final l in lines.take(10)) {
    final t = l.text.trim();
    if (t.length < 3 || t.length > 40) continue;
    if (skip.hasMatch(t)) continue;
    if (RegExp(r'[A-Za-z\u00c0-\u024f\u3040-\u9fff]{3,}').hasMatch(t)) return t;
  }
  return null;
}
