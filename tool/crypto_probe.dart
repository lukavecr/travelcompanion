// ignore_for_file: avoid_print
// Kontrola šifrování SQLite (stejné příkazy jako lib/core/db_crypto.dart): dart run tool/crypto_probe.dart
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final dir = Directory.systemTemp.createTempSync('tc_crypto');
  final path = '${dir.path}/t.sqlite';
  const key = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
  final plain = sqlite3.open(path)
    ..execute('PRAGMA journal_mode = WAL')
    ..execute('CREATE TABLE trips(name TEXT)')
    ..execute("INSERT INTO trips VALUES ('Vietnam')");
  plain.close();
  print('před:  ${String.fromCharCodes(File(path).readAsBytesSync().take(15))}');

  final db = sqlite3.open(path)
    ..execute('PRAGMA wal_checkpoint(TRUNCATE)')
    ..execute('PRAGMA journal_mode = DELETE')
    ..execute("PRAGMA rekey = '$key'");
  db.close();
  final head = File(path).readAsBytesSync().take(15).toList();
  print('po:    ${head.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
  print('obsahuje "Vietnam" v souboru: ${String.fromCharCodes(File(path).readAsBytesSync()).contains('Vietnam')}');

  final ok = sqlite3.open(path)..execute("PRAGMA key = '$key'");
  print('s klíčem: ${ok.select('SELECT name FROM trips').first['name']}');
  ok.close();
  final bad = sqlite3.open(path);
  try {
    bad.select('SELECT name FROM trips');
    print('BEZ klíče: čitelné – CHYBA');
  } catch (e) {
    print('bez klíče: nečitelné ✔');
  } finally {
    bad.close();
  }
  dir.deleteSync(recursive: true);
}
