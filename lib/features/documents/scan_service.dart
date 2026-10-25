import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'field_extractor.dart';
import '../../core/file_crypto.dart';

class ScannedCode {
  const ScannedCode(this.value, this.format);
  final String value;
  final String format;
}

class ScanResult {
  const ScanResult(this.path, this.codes, this.text, [this.fields = const {}]);
  final String path;
  final List<ScannedCode> codes;
  final String text;
  final Map<String, String> fields; // ref, name, date, time, seat, gate, title
}

class OcrResult {
  const OcrResult(this.text, this.lines);
  final String text;
  final List<OcrLine> lines;
}

String _fmt(BarcodeFormat f) {
  switch (f) {
    case BarcodeFormat.qrCode:
      return 'qr';
    case BarcodeFormat.pdf417:
      return 'pdf417';
    case BarcodeFormat.aztec:
      return 'aztec';
    case BarcodeFormat.code128:
      return 'code128';
    case BarcodeFormat.code39:
      return 'code39';
    case BarcodeFormat.ean13:
      return 'ean13';
    case BarcodeFormat.dataMatrix:
      return 'dataMatrix';
    case BarcodeFormat.ean8:
      return 'ean8';
    case BarcodeFormat.upca:
      return 'upca';
    case BarcodeFormat.upce:
      return 'upce';
    case BarcodeFormat.code93:
      return 'code93';
    case BarcodeFormat.codabar:
      return 'codabar';
    case BarcodeFormat.itf:
      return 'itf';
    default:
      return 'unknown';
  }
}

/// Přečte text z obrázku (latinka i japonština) přímo v telefonu.
Future<OcrResult> runOcr(String path) async {
  final input = InputImage.fromFilePath(path);
  final lines = <OcrLine>[];
  for (final script in [TextRecognitionScript.latin, TextRecognitionScript.japanese]) {
    final recognizer = TextRecognizer(script: script);
    try {
      final r = await recognizer.processImage(input);
      for (final b in r.blocks) {
        for (final l in b.lines) {
          if (!lines.any((x) => x.text == l.text)) {
            lines.add(OcrLine(l.text, l.boundingBox));
          }
        }
      }
    } catch (_) {}
    await recognizer.close();
  }
  return OcrResult(lines.map((l) => l.text).join('\n'), lines);
}

/// Přečte kódy a text z obrázku (bez internetu) a spáruje popisky s hodnotami.
Future<ScanResult> scanImage(String path) async {
  final input = InputImage.fromFilePath(path);
  final scanner = BarcodeScanner(formats: [BarcodeFormat.all]);
  final codes = <ScannedCode>[];
  try {
    final found = await scanner.processImage(input);
    for (final b in found) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) codes.add(ScannedCode(v, _fmt(b.format)));
    }
  } catch (_) {}
  await scanner.close();

  final ocr = await runOcr(path);
  final fields = extractFields(ocr.lines);
  final merchant = guessMerchant(ocr.lines);
  if (merchant != null) fields['title'] = merchant;
  return ScanResult(path, codes, ocr.text, fields);
}

/// Uloží obrázek do úložiště aplikace zašifrovaně (AES-256-GCM, klíč v Keystore)
/// a dočasnou kopii z fotoaparátu / galerie smaže.
Future<String> storeImage(String srcPath) async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory(p.join(base.path, 'documents'));
  if (!await dir.exists()) await dir.create(recursive: true);
  final ext = p.extension(srcPath).isEmpty ? '.jpg' : p.extension(srcPath);
  final dest = p.join(dir.path, '${const Uuid().v4()}$ext');
  final src = File(srcPath);
  await FileCrypto.write(dest, await src.readAsBytes());
  try {
    if (p.isWithin((await getTemporaryDirectory()).path, srcPath)) await src.delete();
  } catch (_) {}
  return dest;
}
