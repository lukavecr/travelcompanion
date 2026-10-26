import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/features/documents/field_extractor.dart';
import 'package:travelcompanion/features/money/receipt_reader.dart';

/// Řádek účtenky: popisek vlevo, částka vpravo (dva samostatné kusy OCR, jak je čte ML Kit).
List<OcrLine> rows(List<(String, String?)> r, {double h = 30}) => [
      for (final (i, (label, value)) in r.indexed) ...[
        OcrLine(label, Rect.fromLTWH(40, 100 + i * (h + 12), 300, h)),
        if (value != null) OcrLine(value, Rect.fromLTWH(620, 102 + i * (h + 12), 160, h)),
      ]
    ];

void main() {
  test('Celkem vpravo na stejném řádku (štítek a cena zvlášť)', () {
    final l = rows([
      ('ALBERT HYPERMARKET', null),
      ('26.10.2026 14:32', null),
      ('Rohlík 4 ks', '12,00'),
      ('Mléko 1 l', '24,90'),
      ('Káva zrnková', '219,00'),
      ('CELKEM', '255,90'),
      ('Hotovost', '300,00'),
      ('Vráceno', '44,10'),
      ('DPH 12 %', '27,42'),
    ]);
    expect(guessTotalFromLines(l), 255.90);
  });

  test('restaurace: Subtotal, Tip a Total – vyhraje Total', () {
    final l = rows([
      ('Pad Thai', '180.00'),
      ('Mango shake', '90.00'),
      ('Subtotal', '270.00'),
      ('Service charge 10%', '27.00'),
      ('VAT 7%', '20.79'),
      ('TOTAL', '317.79'),
      ('Cash', '500.00'),
      ('Change', '182.21'),
    ]);
    expect(guessTotalFromLines(l), 317.79);
  });

  test('„K úhradě“ má přednost před „Celkem bez DPH“', () {
    final l = rows([
      ('Celkem bez DPH', '1 000,00'),
      ('DPH 21 %', '210,00'),
      ('Celkem k úhradě', '1 210,00'),
    ]);
    expect(guessTotalFromLines(l), 1210);
  });

  test('japonská účtenka: 合計, ne お預り ani お釣り', () {
    final l = rows([
      ('ラーメン', '¥980'),
      ('餃子', '¥450'),
      ('小計', '¥1,430'),
      ('合計', '¥1,573'),
      ('お預り', '¥2,000'),
      ('お釣り', '¥427'),
    ]);
    expect(guessTotalFromLines(l), 1573);
  });

  test('vietnamská: Tổng cộng, částka pod popiskem', () {
    final l = [
      OcrLine('Phở bò  65.000', const Rect.fromLTWH(40, 100, 500, 30)),
      OcrLine('Tổng cộng:', const Rect.fromLTWH(40, 150, 200, 30)),
      OcrLine('130.000', const Rect.fromLTWH(60, 186, 160, 30)),
    ];
    expect(guessTotalFromLines(l), 130000);
  });

  test('popisek a částka v jednom kusu textu', () {
    final l = [
      OcrLine('Datum 26.10.2026', const Rect.fromLTWH(40, 60, 400, 30)),
      OcrLine('TOTAL EUR 42.50', const Rect.fromLTWH(40, 100, 700, 30)),
    ];
    expect(guessTotalFromLines(l), 42.50);
  });

  test('bez popisku → null (pak rozhodne textová záloha)', () {
    expect(guessTotalFromLines(rows([('Káva', '59'), ('Dort', '89')])), isNull);
  });
}
