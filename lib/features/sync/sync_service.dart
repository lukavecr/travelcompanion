import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database.dart';
import '../documents/email_parser.dart' show emailDocPath;
import '../pro/pro_service.dart';
import 'backup_crypto.dart';
import '../vault/vault_crypto.dart';
import '../vault/vault_sync.dart';
import '../../l10n/tr.dart';
import '../../demo/demo_mode.dart';
import '../../core/file_crypto.dart';
import '../share/shared_trips.dart';

class SyncStatus {
  const SyncStatus({
    this.running = false,
    this.lastSync,
    this.error,
    this.pending = 0,
    this.needsEncryption = false,
  });
  final bool running;
  final DateTime? lastSync;
  final String? error;
  final int pending;
  /// Záloha se odesílá jen šifrovaně – dokud uživatel nenastaví Vault, nic se neodesílá.
  final bool needsEncryption;
}

/// Jedna tabulka z pohledu synchronizace. Pracuje s JSON mapami, takže
/// se stejný kód použije pro všechny tabulky.
class _T {
  _T(
    this.name, {
    required this.pending,
    required this.markSynced,
    required this.localUpdatedAt,
    required this.upsertJson,
  });
  final String name;
  final Future<List<Map<String, dynamic>>> Function() pending;
  final Future<void> Function(Map<String, dynamic> json) markSynced;
  final Future<int?> Function(String id) localUpdatedAt;
  final Future<void> Function(Map<String, dynamic> json) upsertJson;
}

const _realKeys = {'budget', 'lat', 'lng', 'amount', 'fxRate', 'amountMain', 'price', 'distanceM'};
const _maxImageBytes = 650000; // Firestore dokument má limit 1 MiB (base64 +33 %)

class SyncService {
  SyncService(this.db) {
    _loadPrefs();
  }
  final AppDatabase db;
  final status = ValueNotifier<SyncStatus>(const SyncStatus());

  bool _running = false;
  Timer? _debounce;
  StreamSubscription<Set<TableUpdate>>? _sub;
  SharedPreferences? _prefs;
  final Set<String> _uploaded = {};

  Future<SharedPreferences> get _p async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> _loadPrefs() async {
    final prefs = await _p;
    _uploaded.addAll(prefs.getStringList('sync_uploaded') ?? const []);
    final ms = prefs.getInt('sync_last');
    if (ms != null) {
      status.value = SyncStatus(lastSync: DateTime.fromMillisecondsSinceEpoch(ms));
    }
  }

  /// Po změně dat v telefonu (a krátké pauze) odešle, co čeká.
  void start() {
    _sub ??= db.tableUpdates().listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 4), syncIfPending);
    });
  }

  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
  }

  late final List<_T> _tables = [
    _T(
      'trips',
      pending: () async => [
        for (final r in await (db.select(db.trips)
              ..where((t) => t.syncState.equals('pending')))
            .get())
          r.toJson()
      ],
      markSynced: (j) => (db.update(db.trips)
            ..where((t) =>
                t.id.equals(j['id'] as String) &
                t.updatedAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int))))
          .write(TripsCompanion(syncState: Value('synced'))),
      localUpdatedAt: (id) async => (await (db.select(db.trips)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull())
          ?.updatedAt
          .millisecondsSinceEpoch,
      upsertJson: (j) => db
          .into(db.trips)
          .insertOnConflictUpdate(Trip.fromJson({...j, 'syncState': 'synced'})),
    ),
    _T(
      'places',
      pending: () async => [
        for (final r in await (db.select(db.places)
              ..where((t) => t.syncState.equals('pending')))
            .get())
          r.toJson()
      ],
      markSynced: (j) => (db.update(db.places)
            ..where((t) =>
                t.id.equals(j['id'] as String) &
                t.updatedAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int))))
          .write(PlacesCompanion(syncState: Value('synced'))),
      localUpdatedAt: (id) async => (await (db.select(db.places)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull())
          ?.updatedAt
          .millisecondsSinceEpoch,
      upsertJson: (j) => db
          .into(db.places)
          .insertOnConflictUpdate(Place.fromJson({...j, 'syncState': 'synced'})),
    ),
    _T(
      'documents',
      pending: () async => [
        for (final r in await (db.select(db.documents)
              ..where((t) => t.syncState.equals('pending')))
            .get())
          r.toJson()
      ],
      markSynced: (j) => (db.update(db.documents)
            ..where((t) =>
                t.id.equals(j['id'] as String) &
                t.updatedAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int))))
          .write(DocumentsCompanion(syncState: Value('synced'))),
      localUpdatedAt: (id) async => (await (db.select(db.documents)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull())
          ?.updatedAt
          .millisecondsSinceEpoch,
      upsertJson: (j) => db.into(db.documents).insertOnConflictUpdate(
          Document.fromJson({...j, 'syncState': 'synced'})),
    ),
    _T(
      'expenses',
      pending: () async => [
        for (final r in await (db.select(db.expenses)
              ..where((t) => t.syncState.equals('pending')))
            .get())
          r.toJson()
      ],
      markSynced: (j) => (db.update(db.expenses)
            ..where((t) =>
                t.id.equals(j['id'] as String) &
                t.updatedAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int))))
          .write(ExpensesCompanion(syncState: Value('synced'))),
      localUpdatedAt: (id) async => (await (db.select(db.expenses)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull())
          ?.updatedAt
          .millisecondsSinceEpoch,
      upsertJson: (j) => db.into(db.expenses).insertOnConflictUpdate(
          Expense.fromJson({...j, 'syncState': 'synced'})),
    ),
    _T(
      'calendarEvents',
      pending: () async => [
        for (final r in await (db.select(db.calendarEvents)
              ..where((t) => t.syncState.equals('pending')))
            .get())
          r.toJson()
      ],
      markSynced: (j) => (db.update(db.calendarEvents)
            ..where((t) =>
                t.id.equals(j['id'] as String) &
                t.updatedAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int))))
          .write(CalendarEventsCompanion(syncState: Value('synced'))),
      localUpdatedAt: (id) async => (await (db.select(db.calendarEvents)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull())
          ?.updatedAt
          .millisecondsSinceEpoch,
      upsertJson: (j) => db.into(db.calendarEvents).insertOnConflictUpdate(
          CalendarEvent.fromJson({...j, 'syncState': 'synced'})),
    ),
    _T(
      'tickets',
      pending: () async => [
        for (final r in await (db.select(db.tickets)
              ..where((t) => t.syncState.equals('pending')))
            .get())
          r.toJson()
      ],
      markSynced: (j) => (db.update(db.tickets)
            ..where((t) =>
                t.id.equals(j['id'] as String) &
                t.updatedAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int))))
          .write(TicketsCompanion(syncState: Value('synced'))),
      localUpdatedAt: (id) async => (await (db.select(db.tickets)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull())
          ?.updatedAt
          .millisecondsSinceEpoch,
      upsertJson: (j) => db.into(db.tickets).insertOnConflictUpdate(
          Ticket.fromJson({...j, 'syncState': 'synced'})),
    ),
    _T(
      'tracks',
      pending: () async => [
        for (final r in await (db.select(db.tracks)
              ..where((t) => t.syncState.equals('pending')))
            .get())
          r.toJson()
      ],
      markSynced: (j) => (db.update(db.tracks)
            ..where((t) =>
                t.id.equals(j['id'] as String) &
                t.updatedAt.equals(
                    DateTime.fromMillisecondsSinceEpoch(j['updatedAt'] as int))))
          .write(TracksCompanion(syncState: Value('synced'))),
      localUpdatedAt: (id) async => (await (db.select(db.tracks)
                ..where((t) => t.id.equals(id)))
              .getSingleOrNull())
          ?.updatedAt
          .millisecondsSinceEpoch,
      upsertJson: (j) => db.into(db.tracks).insertOnConflictUpdate(
          Track.fromJson({...j, 'syncState': 'synced'})),
    ),
  ];

  Future<int> _pendingCount() async {
    var n = 0;
    for (final t in _tables) {
      n += (await t.pending()).length;
    }
    return n + await vaultPendingCount(db);
  }

  Future<void> syncIfPending() async {
    if (kDemo) return; // prezentační režim nesmí nic zapsat do účtu
    if (_running || FirebaseAuth.instance.currentUser == null) return;
    if (!ProService.instance.isPro) return; // záloha je součást Pro
    if (!await BackupCrypto.instance.active) return; // bez šifrování se nic neodesílá
    final n = await _pendingCount();
    status.value = SyncStatus(
        lastSync: status.value.lastSync, error: status.value.error, pending: n);
    if (n > 0) await syncNow();
  }

  Future<void> syncNow() async {
    if (kDemo) return;
    final user = FirebaseAuth.instance.currentUser;
    if (_running || user == null) return;
    if (!ProService.instance.isPro) return; // záloha je součást Pro
    _running = true;
    status.value = SyncStatus(
        running: true,
        lastSync: status.value.lastSync,
        pending: status.value.pending);
    String? error;
    // záloha je povinně šifrovaná: bez klíče se jen stahuje (stará / šifrovaná záloha), nic se neodesílá
    final encrypted = await BackupCrypto.instance.active;
    try {
      if (encrypted) await _push(user.uid);
      await _pull(user.uid);
      if (encrypted) await _retryMissingFiles(user.uid);
      await syncVault(db, user.uid);
    } catch (e) {
      error = e.toString();
    }
    final pending = await _pendingCount();
    final now = DateTime.now();
    if (error == null) {
      await (await _p).setInt('sync_last', now.millisecondsSinceEpoch);
    }
    status.value = SyncStatus(
      lastSync: error == null && encrypted ? now : status.value.lastSync,
      error: error,
      pending: pending,
      needsEncryption: !encrypted,
    );
    _running = false;
  }

  CollectionReference<Map<String, dynamic>> _col(String uid, String name) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection(name);

  // ---------- odeslání ----------
  Future<void> _push(String uid) async {
    final encrypted = await BackupCrypto.instance.active;
    for (final t in _tables) {
      final rows = await t.pending();
      for (var i = 0; i < rows.length; i += 100) {
        final chunk = rows.sublist(i, math.min(i + 100, rows.length));
        final batch = FirebaseFirestore.instance.batch();
        for (final r in chunk) {
          final id = r['id'] as String;
          final out = Map<String, dynamic>.from(r);

          if (t.name == 'documents') {
            final path = out['localPath'] as String?;
            if (path == emailDocPath) {
              // doklad z textu e-mailu – žádný obrázek
            } else {
              if (path != null && path.isNotEmpty && !path.startsWith('sync:')) {
                await _upload(uid, id, path);
              }
              out['localPath'] = 'sync:file';
            }
          } else if (t.name == 'expenses') {
            final path = out['receiptPath'] as String?;
            if (path != null && path.isNotEmpty && !path.startsWith('sync:')) {
              await _upload(uid, id, path);
            }
            if (path != null) out['receiptPath'] = 'sync:receipt';
          }
          // šifrovaná záloha: do cloudu jen {id, updatedAt, deletedAt, enc}
          batch.set(_col(uid, t.name).doc(id),
              encrypted ? await BackupCrypto.instance.encryptRow(out) : out);
        }
        await batch.commit().timeout(const Duration(seconds: 20));
        for (final r in chunk) {
          await t.markSynced(r);
        }
      }
    }
  }

  // ---------- stažení ----------
  Future<void> _pull(String uid) async {
    final prefs = await _p;
    for (final t in _tables) {
      final key = 'sync_last_${uid}_${t.name}';
      final last = prefs.getInt(key) ?? 0;
      final snap = await _col(uid, t.name)
          .where('updatedAt', isGreaterThan: last)
          .orderBy('updatedAt')
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 30));

      var okUpTo = last;
      for (final d in snap.docs) {
        var j = Map<String, dynamic>.from(d.data());
        if (j.containsKey('enc')) {
          if (!await BackupCrypto.instance.active) {
            // nový telefon: záloha je šifrovaná, klíč odemkne Vault (heslo Vaultu)
            BackupCrypto.instance.lockedRemote = true;
            break;
          }
          j = await BackupCrypto.instance.decryptRow(j);
        }
        final id = j['id'] as String;
        final remoteMs = (j['updatedAt'] as num).toInt();
        j['updatedAt'] = remoteMs;
        for (final k in _realKeys) {
          final v = j[k];
          if (v is int) j[k] = v.toDouble();
        }

        final localMs = await t.localUpdatedAt(id);
        if (localMs == null || localMs < remoteMs) {
          var needsFile = false;
          if (t.name == 'documents' && j['localPath'] == emailDocPath) {
            // bez obrázku
          } else if (t.name == 'documents') {
            final local = await (db.select(db.documents)
                  ..where((x) => x.id.equals(id)))
                .getSingleOrNull();
            final keep = local != null &&
                local.localPath.isNotEmpty &&
                !local.localPath.startsWith('sync:') &&
                File(local.localPath).existsSync();
            j['localPath'] = keep ? local.localPath : '';
            needsFile = !keep;
          } else if (t.name == 'expenses' && j['receiptPath'] != null) {
            final local = await (db.select(db.expenses)
                  ..where((x) => x.id.equals(id)))
                .getSingleOrNull();
            final lp = local?.receiptPath;
            final keep = lp != null &&
                lp.isNotEmpty &&
                !lp.startsWith('sync:') &&
                File(lp).existsSync();
            j['receiptPath'] = keep ? lp : '';
            needsFile = !keep;
          }
          await t.upsertJson(j);
          if (needsFile) await _fetchFileFor(uid, t.name, id);
        }
        okUpTo = math.max(okUpTo, remoteMs);
      }
      if (okUpTo > last) await prefs.setInt(key, okUpTo);
    }
  }

  // ---------- soubory (zmenšené obrázky ve Firestore) ----------
  Future<Uint8List?> _compress(String path) async {
    final plain = await FileCrypto.read(path); // v telefonu je fotka šifrovaná
    var quality = 75;
    var size = 1600;
    for (var i = 0; i < 4; i++) {
      final out = await FlutterImageCompress.compressWithList(
        plain,
        minWidth: size,
        minHeight: size,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (out.length <= _maxImageBytes) return out;
      quality -= 10;
      size = (size * 0.8).round();
    }
    return null;
  }

  Future<void> _upload(String uid, String id, String path) async {
    final key = '$id|$path';
    if (_uploaded.contains(key)) return;
    if (!await File(path).exists()) return;
    final bytes = await _compress(path);
    if (bytes == null) return; // nejde zmenšit, doklad se zazálohuje bez obrázku
    final enc = await BackupCrypto.instance.active;
    await _col(uid, 'files').doc(id).set({
      'b64': base64Encode(enc ? await BackupCrypto.instance.encryptBytes(bytes) : bytes),
      if (enc) 'enc': true,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }).timeout(const Duration(seconds: 30));
    _uploaded.add(key);
    await (await _p).setStringList('sync_uploaded', _uploaded.toList());
  }

  Future<String?> _download(String uid, String id) async {
    try {
      final snap = await _col(uid, 'files')
          .doc(id)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 30));
      final b64 = snap.data()?['b64'] as String?;
      if (b64 == null) return null;
      var bytes = base64Decode(b64);
      if (snap.data()?['enc'] == true) {
        bytes = Uint8List.fromList(await BackupCrypto.instance.decryptBytes(bytes));
      }
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, 'documents'));
      if (!await dir.exists()) await dir.create(recursive: true);
      final path = p.join(dir.path, '$id.jpg');
      await FileCrypto.write(path, bytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchFileFor(String uid, String table, String id) async {
    final path = await _download(uid, id);
    if (path == null) return;
    if (table == 'documents') {
      await (db.update(db.documents)..where((x) => x.id.equals(id)))
          .write(DocumentsCompanion(localPath: Value(path)));
    } else {
      await (db.update(db.expenses)..where((x) => x.id.equals(id)))
          .write(ExpensesCompanion(receiptPath: Value(path)));
    }
  }

  /// Obrázky, které se při stažení nepodařilo dostat, zkusí znovu.
  Future<void> _retryMissingFiles(String uid) async {
    final docs = await (db.select(db.documents)
          ..where((d) => d.localPath.equals('') & d.deletedAt.isNull()))
        .get();
    for (final d in docs) {
      await _fetchFileFor(uid, 'documents', d.id);
    }
    final exps = await (db.select(db.expenses)
          ..where((e) => e.receiptPath.equals('') & e.deletedAt.isNull()))
        .get();
    for (final e in exps) {
      await _fetchFileFor(uid, 'expenses', e.id);
    }
  }
}

extension WipeAll on SyncService {
  /// Smaže všechna data: nejdřív zálohu ve Firestore, pak telefon.
  /// Vault (VaultItems) a účet zůstávají. Výjimka z pravidla „jen soft delete“ –
  /// řádky se mažou natvrdo, aby se znovu neodeslaly ani nestáhly.
  /// Když selže cloud, telefon se nemaže (vyhodí výjimku).
  Future<void> wipeAllData({bool includeVault = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception(tr('Nejsi přihlášený.'));
    if (_running) throw Exception(tr('Právě probíhá synchronizace, zkus to za chvíli.'));
    _running = true;
    _debounce?.cancel();
    try {
      // 1) cloud
      for (final name in [
        ..._tables.map((t) => t.name),
        'files',
        if (includeVault) ...['vault', 'vault_files', 'vault_meta'],
      ]) {
        final col = _col(user.uid, name);
        while (true) {
          final snap = await col
              .limit(200)
              .get(const GetOptions(source: Source.server))
              .timeout(const Duration(seconds: 30));
          if (snap.docs.isEmpty) break;
          final batch = FirebaseFirestore.instance.batch();
          for (final d in snap.docs) {
            batch.delete(d.reference);
          }
          await batch.commit().timeout(const Duration(seconds: 30));
        }
      }

      // 2) soubory v telefonu (fotky dokladů a účtenek)
      final paths = <String>[
        for (final d in await db.select(db.documents).get()) d.localPath,
        for (final e in await db.select(db.expenses).get()) e.receiptPath ?? '',
      ];
      for (final path in paths) {
        if (path.isEmpty || path.startsWith('sync:')) continue;
        try {
          await File(path).delete();
        } catch (_) {}
      }

      // 3) databáze v telefonu (bez Vaultu)
      await db.transaction(() async {
        for (final t in <TableInfo<Table, dynamic>>[
          db.tickets,
          db.calendarEvents,
          db.expenses,
          db.documents,
          db.places,
          db.photos,
          db.tracks,
          db.trips,
          if (includeVault) db.vaultItems,
        ]) {
          await db.delete(t).go();
        }
      });

      // 4) stav synchronizace
      final prefs = await _p;
      if (includeVault) {
        try {
          await Directory(p.join((await getApplicationDocumentsDirectory()).path, 'vault'))
              .delete(recursive: true);
        } catch (_) {}
        await VaultKeys.instance.forget();
        await BackupCrypto.instance.forget();
      }
      for (final k in prefs
          .getKeys()
          .where((k) => k.startsWith('sync_') || (includeVault && k.startsWith('vault_')))
          .toList()) {
        await prefs.remove(k);
      }
      _uploaded.clear();
      status.value = const SyncStatus();
    } finally {
      _running = false;
    }
  }
}

extension EncryptBackup on SyncService {
  /// Zapne šifrovanou zálohu a všechno v ní přepíše zašifrovaně (řádky i obrázky).
  /// Vrací kód chyby (`vault-locked`, `not-signed-in`…) nebo null.
  Future<String?> enableEncryptedBackup() async {
    final err = await BackupCrypto.instance.enable();
    if (err != null) return err;
    // všechno znovu označit k odeslání → přepíše se zašifrovanou verzí
    await db.transaction(() async {
      for (final t in <TableInfo<Table, dynamic>>[
        db.trips, db.places, db.documents, db.expenses, db.calendarEvents, db.tickets, db.tracks,
      ]) {
        await db.customUpdate("UPDATE ${t.actualTableName} SET sync_state = 'pending'",
            updates: {t});
      }
    });
    _uploaded.clear();
    await (await _p).remove('sync_uploaded');
    await syncNow();
    if (status.value.error != null) return status.value.error;
    await _deletePlainFiles();
    await SharedTrips.instance.resaveKeys(); // klíče společných cest v záloze teď šifrovaně
    return null;
  }

  /// Po zapnutí šifrování smaže z cloudu obrázky, které tam zůstaly nešifrované (např. ze smazaných dokladů).
  Future<void> _deletePlainFiles() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final snap = await _col(uid, 'files').get(const GetOptions(source: Source.server));
      for (final d in snap.docs) {
        if (d.data()['enc'] != true) await d.reference.delete();
      }
    } catch (e) {
      debugPrint('deletePlainFiles: $e');
    }
  }

  /// Záloha je povinně šifrovaná: po odemčení Vaultu klíč zálohy obnoví (jiný telefon) nebo vytvoří.
  Future<void> ensureEncryptedBackup() async {
    if (!ProService.instance.isPro || FirebaseAuth.instance.currentUser == null) return;
    final bc = BackupCrypto.instance;
    if (!await bc.active) await bc.restoreFromVault();
    if (!await bc.active && VaultKeys.instance.unlocked) {
      await enableEncryptedBackup();
      return;
    }
    await syncNow();
  }
}

extension DeleteAccount on SyncService {
  /// Smaže úplně vše (i Vault) v telefonu i v záloze a nakonec účet ve Firebase.
  /// Firebase chce k smazání účtu čerstvé přihlášení → heslo účtu.
  /// Vrací chybovou hlášku pro uživatele, nebo null když se povedlo.
  Future<String?> deleteAccount(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return tr('Nejsi přihlášený.');
    try {
      await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password));
    } on FirebaseAuthException catch (e) {
      return switch (e.code) {
        'wrong-password' || 'invalid-credential' => tr('Špatné heslo účtu.'),
        'network-request-failed' => tr('Nejsi připojený k internetu.'),
        _ => tr('Ověření se nepovedlo ({code}).', {'code': e.code}),
      };
    }
    try {
      await wipeAllData(includeVault: true);
      await user.delete();
      await FirebaseAuth.instance.signOut();
      return null;
    } catch (e) {
      return tr('Smazání se nepovedlo: {e}', {'e': e});
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final s = SyncService(ref.watch(databaseProvider));
  ref.onDispose(s.dispose);
  return s;
});
