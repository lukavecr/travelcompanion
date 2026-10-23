import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../vault/vault_crypto.dart';

/// Šifrovaná záloha (cesty, plán, místa, doklady, výdaje, obrázky).
///
/// * Záloha má vlastní náhodný klíč (256 bit) uložený v Android Keystore – synchronizace
///   tak běží i se zamčeným Vaultem.
/// * Pro obnovu na novém telefonu je klíč zálohy ve Firestore (`vault_meta/key.backupKey`)
///   zašifrovaný **hlavním klíčem Vaultu** → odemkne ho heslo Vaultu.
/// * Dokument ve Firestore: `{id, updatedAt, deletedAt, enc}` – `enc` = AES-256-GCM(JSON řádku).
///   `updatedAt` zůstává čitelný kvůli dotazům na změny (nic neprozrazuje).
class BackupCrypto extends ChangeNotifier {
  BackupCrypto._();
  static final instance = BackupCrypto._();

  static const _storage = FlutterSecureStorage();
  static const _keyName = 'backup_key_v1';
  static final _aes = AesGcm.with256bits();

  SecretKey? _key;
  bool _loaded = false;

  /// Je šifrování zálohy v tomto telefonu zapnuté (klíč je k dispozici)?
  Future<bool> get active async => (await _getKey()) != null;

  /// Šifrovaná záloha je zapnutá na účtu, ale klíč v telefonu chybí (nový telefon) → odemknout Vault.
  bool lockedRemote = false;

  Future<SecretKey?> _getKey() async {
    if (!_loaded) {
      final b64 = await _storage.read(key: _keyName);
      if (b64 != null) _key = SecretKey(base64Decode(b64));
      _loaded = true;
    }
    return _key;
  }

  static DocumentReference<Map<String, dynamic>> _metaRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('vault_meta').doc('key');

  /// Zapne šifrování: vytvoří klíč zálohy, zamkne ho klíčem Vaultu do cloudu a uloží do Keystore.
  /// Vault musí být odemčený. Vrací chybu pro uživatele, nebo null.
  Future<String?> enable() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'not-signed-in';
    if (!VaultKeys.instance.unlocked) return 'vault-locked';
    if (await active) return null;
    final raw = List<int>.generate(32, (_) => Random.secure().nextInt(256));
    final wrapped = await VaultKeys.instance.encryptBytes(raw);
    await _metaRef(uid).set({'backupKey': base64Encode(wrapped)}, SetOptions(merge: true));
    await _storage.write(key: _keyName, value: base64Encode(raw));
    _key = SecretKey(raw);
    _loaded = true;
    lockedRemote = false;
    notifyListeners();
    return null;
  }

  /// Na novém telefonu po odemčení/obnově Vaultu: stáhne klíč zálohy a odemkne ho klíčem Vaultu.
  Future<void> restoreFromVault() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !VaultKeys.instance.unlocked || await active) return;
    try {
      final snap = await _metaRef(uid).get(const GetOptions(source: Source.server));
      final b64 = snap.data()?['backupKey'] as String?;
      if (b64 == null) return;
      final raw = await VaultKeys.instance.decryptBytes(base64Decode(b64));
      await _storage.write(key: _keyName, value: base64Encode(raw));
      _key = SecretKey(raw);
      _loaded = true;
      lockedRemote = false;
      notifyListeners();
    } catch (_) {}
  }

  /// Smazání účtu: zapomenout klíč v telefonu.
  Future<void> forget() async {
    await _storage.delete(key: _keyName);
    _key = null;
    _loaded = true;
    notifyListeners();
  }

  // ---------- šifrování řádků a souborů ----------

  Future<Map<String, dynamic>> encryptRow(Map<String, dynamic> row) async =>
      encryptRowWith((await _getKey())!, row);

  Future<Map<String, dynamic>> decryptRow(Map<String, dynamic> doc) async {
    final k = await _getKey();
    if (k == null) throw StateError('backup-key-missing');
    return decryptRowWith(k, doc);
  }

  Future<List<int>> encryptBytes(List<int> data) async =>
      (await _aes.encrypt(data, secretKey: (await _getKey())!)).concatenation();

  Future<List<int>> decryptBytes(List<int> data) async {
    final k = await _getKey();
    if (k == null) throw StateError('backup-key-missing');
    return _aes.decrypt(_box(data), secretKey: k);
  }

  static SecretBox _box(List<int> d) => SecretBox.fromConcatenation(d,
      nonceLength: _aes.nonceLength, macLength: _aes.macAlgorithm.macLength);

  /// Řádek → `{id, updatedAt, deletedAt, enc}` (testovatelné bez telefonu).
  static Future<Map<String, dynamic>> encryptRowWith(SecretKey k, Map<String, dynamic> row) async {
    final box = await _aes.encrypt(utf8.encode(jsonEncode(row)), secretKey: k);
    return {
      'id': row['id'],
      'updatedAt': row['updatedAt'],
      'deletedAt': row['deletedAt'],
      'enc': base64Encode(box.concatenation()),
    };
  }

  static Future<Map<String, dynamic>> decryptRowWith(SecretKey k, Map<String, dynamic> doc) async {
    final plain = await _aes.decrypt(_box(base64Decode(doc['enc'] as String)), secretKey: k);
    return Map<String, dynamic>.from(jsonDecode(utf8.decode(plain)) as Map);
  }
}
