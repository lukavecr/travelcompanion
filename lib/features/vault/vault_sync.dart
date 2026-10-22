import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database.dart';
import 'vault_repository.dart';

/// Záloha Vaultu: do Firestore jde jen zašifrovaný obsah (klíč zůstává v telefonu).
///  * `users/{uid}/vault/{id}` – {type, expiresAt, blob (base64 AES-GCM), updatedAt, deletedAt}
///  * `users/{uid}/vault_files/{id}` – zašifrovaná fotka (base64)
/// Na šifrování není potřeba odemčený Vault – posílá se už zašifrované.

CollectionReference<Map<String, dynamic>> _col(String uid, String name) =>
    FirebaseFirestore.instance.collection('users').doc(uid).collection(name);

Future<int> vaultPendingCount(AppDatabase db) async {
  final rows = await (db.select(db.vaultItems)..where((v) => v.syncState.equals('pending'))).get();
  final prefs = await SharedPreferences.getInstance();
  return rows.length +
      (prefs.getStringList(prefUploadPending)?.length ?? 0) +
      (prefs.getStringList(prefRemoteDelete)?.length ?? 0);
}

Future<void> syncVault(AppDatabase db, String uid) async {
  final prefs = await SharedPreferences.getInstance();

  // 1) fotky nahoru
  for (final id in List<String>.from(prefs.getStringList(prefUploadPending) ?? const [])) {
    final f = await VaultRepository.photoFile(id);
    if (await f.exists()) {
      await _col(uid, 'vault_files').doc(id).set({
        'b64': base64Encode(await f.readAsBytes()),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }).timeout(const Duration(seconds: 30));
    }
    final l = prefs.getStringList(prefUploadPending) ?? [];
    await prefs.setStringList(prefUploadPending, l.where((x) => x != id).toList());
  }

  // 2) smazané fotky pryč i ze zálohy
  for (final id in List<String>.from(prefs.getStringList(prefRemoteDelete) ?? const [])) {
    await _col(uid, 'vault_files').doc(id).delete().timeout(const Duration(seconds: 20));
    final l = prefs.getStringList(prefRemoteDelete) ?? [];
    await prefs.setStringList(prefRemoteDelete, l.where((x) => x != id).toList());
  }

  // 3) položky nahoru
  final pending =
      await (db.select(db.vaultItems)..where((v) => v.syncState.equals('pending'))).get();
  for (final r in pending) {
    await _col(uid, 'vault').doc(r.id).set({
      'id': r.id,
      'type': r.type,
      'blob': base64Encode(r.encryptedBlob),
      'expiresAt': r.expiresAt?.millisecondsSinceEpoch,
      'updatedAt': r.updatedAt.millisecondsSinceEpoch,
      'deletedAt': r.deletedAt?.millisecondsSinceEpoch,
    }).timeout(const Duration(seconds: 20));
    await (db.update(db.vaultItems)
          ..where((v) => v.id.equals(r.id) & v.updatedAt.equals(r.updatedAt)))
        .write(const VaultItemsCompanion(syncState: Value('synced')));
  }

  // 4) položky dolů (z jiného telefonu / po obnově)
  final key = 'vault_last_$uid';
  final last = prefs.getInt(key) ?? 0;
  final snap = await _col(uid, 'vault')
      .where('updatedAt', isGreaterThan: last)
      .orderBy('updatedAt')
      .get(const GetOptions(source: Source.server))
      .timeout(const Duration(seconds: 30));
  var okUpTo = last;
  for (final d in snap.docs) {
    final j = d.data();
    final remoteMs = (j['updatedAt'] as num).toInt();
    final local =
        await (db.select(db.vaultItems)..where((v) => v.id.equals(d.id))).getSingleOrNull();
    if (local == null || local.updatedAt.millisecondsSinceEpoch < remoteMs) {
      DateTime? ms(Object? v) =>
          v == null ? null : DateTime.fromMillisecondsSinceEpoch((v as num).toInt());
      await db.into(db.vaultItems).insertOnConflictUpdate(VaultItemsCompanion.insert(
            id: d.id,
            type: j['type'] as String,
            encryptedBlob: base64Decode(j['blob'] as String),
            expiresAt: Value(ms(j['expiresAt'])),
            updatedAt: Value(ms(remoteMs)!),
            deletedAt: Value(ms(j['deletedAt'])),
            syncState: const Value('synced'),
          ));
    }
    okUpTo = math.max(okUpTo, remoteMs);
  }
  if (okUpTo > last) await prefs.setInt(key, okUpTo);
}

/// Zašifrovaná fotka ze zálohy (null = není / offline).
Future<Uint8List?> downloadVaultPhoto(String id) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  try {
    final snap = await _col(uid, 'vault_files')
        .doc(id)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 30));
    final b64 = snap.data()?['b64'] as String?;
    return b64 == null ? null : base64Decode(b64);
  } catch (_) {
    return null;
  }
}
