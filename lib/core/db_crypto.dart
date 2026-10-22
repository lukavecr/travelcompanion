import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Šifrování databáze v telefonu (SQLite3MultipleCiphers, viz `hooks` v pubspec.yaml).
/// Klíč je náhodný, uložený v Android Keystore (flutter_secure_storage), nikdy se nezálohuje.

const _storage = FlutterSecureStorage();
const _keyName = 'db_key_v1';
const dbName = 'travelcompanion';

Future<String> databaseKey() async {
  final existing = await _storage.read(key: _keyName);
  if (existing != null && existing.isNotEmpty) return existing;
  final r = Random.secure();
  final key = List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  await _storage.write(key: _keyName, value: key);
  return key;
}

/// Příkaz pro otevření šifrované databáze (klíč je hex, bez uvozovek uvnitř).
String keyPragma(String key) => "PRAGMA key = '$key'";

Future<String> databasePath() async =>
    p.join((await getApplicationDocumentsDirectory()).path, '$dbName.sqlite');

/// Starou nešifrovanou databázi (z verzí před šifrováním) jednorázově zašifruje.
/// Při chybě nechá původní soubor beze změny.
Future<void> encryptLegacyDatabase(String key) async {
  final file = File(await databasePath());
  if (!await file.exists()) return;
  final head = await file.openRead(0, 15).fold<List<int>>([], (a, b) => a..addAll(b));
  if (String.fromCharCodes(head) != 'SQLite format 3') return; // už je šifrovaná

  final backup = File('${file.path}.plain-backup');
  await file.copy(backup.path);
  try {
    final db = sqlite3.open(file.path);
    try {
      db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
      db.execute('PRAGMA journal_mode = DELETE'); // rekey nejde v režimu WAL
      db.execute("PRAGMA rekey = '$key'");
    } finally {
      db.close();
    }
    // kontrola: s klíčem musí jít číst
    final check = sqlite3.open(file.path);
    try {
      check.execute(keyPragma(key));
      check.select('SELECT count(*) FROM sqlite_master');
    } finally {
      check.close();
    }
    await backup.delete();
  } catch (_) {
    await backup.copy(file.path); // vrátit původní stav
    await backup.delete();
    rethrow;
  }
}
