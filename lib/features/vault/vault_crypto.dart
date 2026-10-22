import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../lock/app_lock.dart';

/// Šifrování Vaultu.
///
/// Náhodný hlavní klíč Vaultu (256 bit) je uložený dvakrát:
///  * v Android Keystore (flutter_secure_storage) – denní odemykání otiskem/PINem,
///  * zašifrovaný klíčem odvozeným z **hesla Vaultu** (PBKDF2-SHA256) ve Firestore
///    `users/{uid}/vault_meta/key` – obnova na novém telefonu.
/// Položky i fotky se šifrují AES-256-GCM; do zálohy jdou jen zašifrované.
/// Heslo ani hlavní klíč nikdy neopouští telefon v čitelné podobě.
class VaultKeys extends ChangeNotifier {
  VaultKeys._();
  static final instance = VaultKeys._();

  static const _storage = FlutterSecureStorage();
  static const _localKeyName = 'vault_key_v1';
  static const _iterations = 310000;
  static final _aes = AesGcm.with256bits();

  SecretKey? _key;
  bool get unlocked => _key != null;

  /// Zamkne Vault (klíč zmizí z paměti).
  void lock() {
    if (_key == null) return;
    _key = null;
    notifyListeners();
  }

  /// Zapomene klíč v telefonu (jen při smazání účtu).
  Future<void> forget() async {
    await _storage.delete(key: _localKeyName);
    lock();
  }

  Future<bool> hasLocalKey() async =>
      (await _storage.read(key: _localKeyName))?.isNotEmpty == true;

  static DocumentReference<Map<String, dynamic>> _metaRef(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('vault_meta').doc('key');

  /// Existuje už Vault v záloze (z jiného telefonu)? null = nejde zjistit (offline).
  Future<bool?> remoteExists() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final snap = await _metaRef(uid)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 15));
      return snap.exists;
    } catch (_) {
      return null;
    }
  }

  static Future<SecretKey> _derive(String password, List<int> salt, int iterations) =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256)
          .deriveKeyFromPassword(password: password, nonce: salt);

  static List<int> _random(int n) {
    final r = Random.secure();
    return List.generate(n, (_) => r.nextInt(256));
  }

  /// Nový Vault: vytvoří hlavní klíč, zašifruje ho heslem a uloží do zálohy i do Keystore.
  /// Vyžaduje internet (aby nevznikly dva různé Vaulty).
  Future<void> setup(String password) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Nejsi přihlášený.');
    final master = _random(32);
    final salt = _random(16);
    final wrapKey = await _derive(password, salt, _iterations);
    final box = await _aes.encrypt(master, secretKey: wrapKey);
    await _metaRef(uid).set({
      'v': 1,
      'kdf': 'pbkdf2-sha256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'wrapped': base64Encode(box.concatenation()),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }).timeout(const Duration(seconds: 20));
    await _storage.write(key: _localKeyName, value: base64Encode(master));
    _key = SecretKey(master);
    notifyListeners();
  }

  /// Obnova na novém telefonu heslem Vaultu. false = špatné heslo.
  Future<bool> restore(String password) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Nejsi přihlášený.');
    final snap = await _metaRef(uid)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 20));
    final m = snap.data();
    if (m == null) throw Exception('Vault v záloze není.');
    final wrapKey = await _derive(
        password, base64Decode(m['salt'] as String), (m['iterations'] as num).toInt());
    try {
      final master = await _aes.decrypt(
        SecretBox.fromConcatenation(base64Decode(m['wrapped'] as String),
            nonceLength: _aes.nonceLength, macLength: _aes.macAlgorithm.macLength),
        secretKey: wrapKey,
      );
      await _storage.write(key: _localKeyName, value: base64Encode(master));
      _key = SecretKey(master);
      notifyListeners();
      return true;
    } on SecretBoxAuthenticationError {
      return false;
    }
  }

  /// Denní odemčení otiskem / PINem telefonu.
  Future<bool> unlockWithDevice() async {
    if (unlocked) return true;
    final hasLock = await DeviceAuth.deviceHasLock();
    if (hasLock && !await DeviceAuth.confirm('Odemkni Vault')) return false;
    final b64 = await _storage.read(key: _localKeyName);
    if (b64 == null) return false;
    _key = SecretKey(base64Decode(b64));
    notifyListeners();
    return true;
  }

  SecretKey get _k {
    final k = _key;
    if (k == null) throw StateError('Vault je zamčený');
    return k;
  }

  Future<Uint8List> encryptBytes(List<int> plain) async =>
      Uint8List.fromList((await _aes.encrypt(plain, secretKey: _k)).concatenation());

  Future<Uint8List> decryptBytes(List<int> data) async => Uint8List.fromList(await _aes.decrypt(
        SecretBox.fromConcatenation(data,
            nonceLength: _aes.nonceLength, macLength: _aes.macAlgorithm.macLength),
        secretKey: _k,
      ));

  Future<Uint8List> encryptJson(Map<String, dynamic> json) =>
      encryptBytes(utf8.encode(jsonEncode(json)));

  Future<Map<String, dynamic>> decryptJson(List<int> data) async =>
      jsonDecode(utf8.decode(await decryptBytes(data))) as Map<String, dynamic>;
}
