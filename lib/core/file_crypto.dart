import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Šifrování souborů v telefonu (fotky dokladů a účtenek): AES-256-GCM, klíč v Android Keystore.
///
/// Soubor = „TCE1“ + nonce + šifrovaný obsah + MAC. Soubory bez hlavičky (ze starších verzí) se čtou
/// tak, jak jsou, a [encryptExistingFiles] je při startu jednorázově zašifruje.
class FileCrypto {
  FileCrypto._();

  static const _storage = FlutterSecureStorage();
  static const _keyName = 'file_key_v1';
  static final _magic = ascii.encode('TCE1');
  static final _aes = AesGcm.with256bits();
  static SecretKey? _key;

  static Future<SecretKey> _k() async {
    final k = _key;
    if (k != null) return k;
    var b64 = await _storage.read(key: _keyName);
    if (b64 == null || b64.isEmpty) {
      final r = Random.secure();
      b64 = base64Encode(List<int>.generate(32, (_) => r.nextInt(256)));
      await _storage.write(key: _keyName, value: b64);
    }
    return _key = SecretKey(base64Decode(b64));
  }

  static bool isEncrypted(List<int> bytes) =>
      bytes.length > 4 && bytes[0] == _magic[0] && bytes[1] == _magic[1] && bytes[2] == _magic[2] && bytes[3] == _magic[3];

  static Future<Uint8List> encrypt(List<int> plain) async {
    final box = await _aes.encrypt(plain, secretKey: await _k());
    return Uint8List.fromList([..._magic, ...box.concatenation()]);
  }

  static Future<Uint8List> decrypt(List<int> data) async {
    if (!isEncrypted(data)) return Uint8List.fromList(data);
    final box = SecretBox.fromConcatenation(data.sublist(4),
        nonceLength: _aes.nonceLength, macLength: _aes.macAlgorithm.macLength);
    return Uint8List.fromList(await _aes.decrypt(box, secretKey: await _k()));
  }

  /// Obsah souboru v čitelné podobě (šifrovaný i starý nešifrovaný).
  static Future<Uint8List> read(String path) async => decrypt(await File(path).readAsBytes());

  /// Zapíše obsah zašifrovaně (přes dočasný soubor, aby se při pádu nic nepoškodilo).
  static Future<void> write(String path, List<int> plain) async {
    final tmp = File('$path.tmp');
    await tmp.writeAsBytes(await encrypt(plain), flush: true);
    await tmp.rename(path);
  }

  /// Jednorázově zašifruje fotky uložené starší verzí aplikace.
  static Future<void> encryptExistingFiles() async {
    try {
      final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'documents'));
      if (!await dir.exists()) return;
      await for (final f in dir.list()) {
        if (f is! File || f.path.endsWith('.tmp')) continue;
        final head = await f.openRead(0, 4).fold<List<int>>([], (a, b) => a..addAll(b));
        if (isEncrypted([...head, 0])) continue;
        await write(f.path, await f.readAsBytes());
      }
    } catch (e) {
      debugPrint('encryptExistingFiles: $e');
    }
  }

  /// Smaže dočasné soubory (exporty, fotky z fotoaparátu, obrázky ke sdílení) starší než 10 minut.
  static Future<void> cleanTemp() async {
    try {
      final tmp = await getTemporaryDirectory();
      final limit = DateTime.now().subtract(const Duration(minutes: 10));
      final export = Directory(p.join(tmp.path, 'export'));
      if (await export.exists()) await export.delete(recursive: true);
      await for (final f in tmp.list()) {
        if (f is! File) continue;
        final ext = p.extension(f.path).toLowerCase();
        if (!const {'.jpg', '.jpeg', '.png', '.heic', '.webp', '.gpx', '.pdf', '.ics', '.csv', '.json'}.contains(ext)) continue;
        if ((await f.lastModified()).isBefore(limit)) await f.delete();
      }
    } catch (_) {}
  }
}

/// Obrázek ze šifrovaného souboru (i ze staršího nešifrovaného).
class EncryptedImage extends StatelessWidget {
  const EncryptedImage(this.path, {super.key, this.fit, this.width, this.height, this.errorText});
  final String path;
  final BoxFit? fit;
  final double? width, height;
  final String? errorText;

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
        future: FileCrypto.read(path),
        builder: (context, snap) {
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Text(errorText ?? '—', textAlign: TextAlign.center),
            );
          }
          if (!snap.hasData) {
            return SizedBox(width: width, height: height ?? 120, child: const Center(child: CircularProgressIndicator()));
          }
          return Image.memory(snap.data!, fit: fit, width: width, height: height, gaplessPlayback: true);
        },
      );
}
