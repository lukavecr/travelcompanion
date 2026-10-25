import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/database.dart';
import '../sync/backup_crypto.dart';
import 'share_logic.dart';
import '../../demo/demo_mode.dart';

/// Účastník společné cesty.
class TripMember {
  const TripMember(this.uid, this.name, this.role);
  final String uid;
  final String name;
  final String role; // owner | member
  Map<String, String> toJson() => {'uid': uid, 'name': name, 'role': role};
  factory TripMember.fromJson(Map j) =>
      TripMember(j['uid'] as String, j['name'] as String? ?? '?', j['role'] as String? ?? 'member');
}

/// Společné cesty: plán, místa a výdaje cesty sdílené s dalšími lidmi.
///
/// Firestore: `shared/{tripId}` (ownerUid, rev), `shared/{tripId}/members/{uid}` (jméno, role),
/// `shared/{tripId}/{trips|places|expenses|calendarEvents}/{id}` = řádek šifrovaný **klíčem cesty**
/// (AES-256-GCM, stejně jako šifrovaná záloha). Klíč cesty dostane pozvaný v kódu pozvánky,
/// do cloudu jde jen zamčený kódem (`invites/{hash kódu}`). Každý účastník má kopii klíče
/// ve vlastní záloze `users/{uid}/shared_trips/{tripId}` (zašifrovanou klíčem zálohy, je-li zapnutý).
///
/// Na rozdíl od zálohy (jen Pro) běží pro všechny přihlášené – pozvaní můžou mít verzi zdarma.
/// Synchronizace: změna v telefonu → odeslání řádků cesty novějších než poslední odeslání;
/// odeslání zvýší `rev` → ostatním přijde změna dokumentu cesty → stáhnou novější řádky.
class SharedTrips extends ChangeNotifier {
  SharedTrips._();
  static final instance = SharedTrips._();

  static const _storage = FlutterSecureStorage();
  static const tables = ['trips', 'places', 'expenses', 'calendarEvents']; // pořadí kvůli vazbám
  static const _realKeys = {'budget', 'lat', 'lng', 'amount', 'fxRate', 'amountMain'};

  AppDatabase? _db;
  final _keys = <String, SecretKey>{};
  final members = <String, List<TripMember>>{};
  final _subs = <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
  final _received = <String, int>{}; // id → updatedAt stažené verze (neposílat zpět)
  StreamSubscription<Set<TableUpdate>>? _localSub;
  StreamSubscription<User?>? _authSub;
  Timer? _debounce;
  bool _pushing = false;
  /// Cesty, ze kterých mě majitel odebral (zobrazí se upozornění).
  final removed = <String>{};

  static FirebaseFirestore get _fs => FirebaseFirestore.instance;
  static String? get myUid => FirebaseAuth.instance.currentUser?.uid;
  static DocumentReference<Map<String, dynamic>> _trip(String id) => _fs.collection('shared').doc(id);
  static const _net = Duration(seconds: 20);

  void start(AppDatabase db) {
    if (kDemo) return; // prezentační režim: žádné sdílení
    _db = db;
    _authSub ??= FirebaseAuth.instance.authStateChanges().listen((u) {
      if (u != null) unawaited(_attachAll());
    });
    _localSub ??= db
        .tableUpdates(TableUpdateQuery.onAllTables([db.trips, db.places, db.expenses, db.calendarEvents]))
        .listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 3), pushAll);
    });
  }

  Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // ---------- klíče ----------

  Future<SecretKey?> _key(String tripId) async {
    final k = _keys[tripId];
    if (k != null) return k;
    final b64 = await _storage.read(key: 'trip_key_$tripId');
    if (b64 != null) return _keys[tripId] = SecretKey(base64Decode(b64));
    // nový telefon: kopie klíče ve vlastní záloze
    final uid = myUid;
    if (uid == null) return null;
    try {
      final d = await _fs.collection('users').doc(uid).collection('shared_trips').doc(tripId).get();
      final data = d.data();
      if (data == null) return null;
      var raw = base64Decode(data['key'] as String);
      if (data['enc'] == true) {
        if (!await BackupCrypto.instance.active) return null;
        raw = Uint8List.fromList(await BackupCrypto.instance.decryptBytes(raw));
      }
      await _saveKey(tripId, raw, backup: false);
      return _keys[tripId];
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveKey(String tripId, List<int> raw, {String? role, bool backup = true}) async {
    await _storage.write(key: 'trip_key_$tripId', value: base64Encode(raw));
    _keys[tripId] = SecretKey(raw);
    final uid = myUid;
    if (!backup || uid == null) return;
    final enc = await BackupCrypto.instance.active;
    await _fs.collection('users').doc(uid).collection('shared_trips').doc(tripId).set({
      'key': base64Encode(enc ? await BackupCrypto.instance.encryptBytes(raw) : raw),
      'enc': enc,
      if (role != null) 'role': role,
    }, SetOptions(merge: true));
  }

  /// Po zapnutí šifrované zálohy uloží kopie klíčů společných cest do zálohy znovu – zašifrovaně.
  Future<void> resaveKeys() async {
    final db = _db;
    if (db == null) return;
    for (final t in await (db.select(db.trips)..where((t) => t.shareRole.isNotNull())).get()) {
      final k = await _key(t.id);
      if (k != null) await _saveKey(t.id, await k.extractBytes(), role: t.shareRole);
    }
  }

  // ---------- členové ----------

  Future<void> _loadMembers(String tripId) async {
    try {
      final snap = await _trip(tripId).collection('members').get();
      members[tripId] = [
        for (final d in snap.docs)
          TripMember(d.id, d.data()['name'] as String? ?? '?', d.data()['role'] as String? ?? 'member')
      ]..sort((a, b) => a.role == 'owner' ? -1 : (b.role == 'owner' ? 1 : a.name.compareTo(b.name)));
      (await _p).setString('share_members_$tripId', jsonEncode([for (final m in members[tripId]!) m.toJson()]));
    } catch (_) {
      final cached = (await _p).getString('share_members_$tripId');
      if (cached != null) {
        members[tripId] = [for (final m in jsonDecode(cached) as List) TripMember.fromJson(m as Map)];
      }
    }
    notifyListeners();
  }

  List<TripMember> membersOf(String tripId) => members[tripId] ?? const [];
  String nameOf(String tripId, String? uid) {
    for (final m in membersOf(tripId)) {
      if (m.uid == uid) return m.name;
    }
    return '?';
  }

  // ---------- napojení ----------

  /// Všechny společné cesty: z telefonu + přidané na jiném telefonu (vlastní seznam v cloudu).
  Future<void> _attachAll() async {
    final db = _db, uid = myUid;
    if (db == null || uid == null) return;
    final ids = <String>{
      for (final t in await (db.select(db.trips)..where((t) => t.shareRole.isNotNull())).get()) t.id
    };
    try {
      final mine = await _fs.collection('users').doc(uid).collection('shared_trips').get();
      ids.addAll(mine.docs.map((d) => d.id));
    } catch (_) {}
    for (final id in ids) {
      _attach(id);
    }
  }

  void _attach(String tripId) {
    if (_subs.containsKey(tripId)) return;
    var first = true;
    _subs[tripId] = _trip(tripId).snapshots().listen((s) async {
      if (!s.exists) {
        if (!first) await _lost(tripId);
        first = false;
        return;
      }
      first = false;
      await pull(tripId);
    }, onError: (Object e) async {
      if (e is FirebaseException && e.code == 'permission-denied') await _lost(tripId);
    });
    unawaited(_loadMembers(tripId));
  }

  /// Už nejsem členem (odebrání nebo zrušení sdílení) – cesta zůstane jako moje kopie.
  Future<void> _lost(String tripId) async {
    await _subs.remove(tripId)?.cancel();
    final db = _db;
    if (db == null) return;
    final t = await (db.select(db.trips)..where((x) => x.id.equals(tripId))).getSingleOrNull();
    if (t?.shareRole == 'member') {
      await (db.update(db.trips)..where((x) => x.id.equals(tripId))).write(TripsCompanion(
          shareRole: const Value(null), updatedAt: Value(DateTime.now()), syncState: const Value('pending')));
      removed.add(tripId);
      notifyListeners();
    }
  }

  // ---------- stažení ----------

  Future<void> pull(String tripId) async {
    final db = _db;
    final k = await _key(tripId);
    if (db == null || k == null) return;
    final prefs = await _p;
    final role = (await _trip(tripId).get()).data()?['ownerUid'] == myUid ? 'owner' : 'member';
    var changed = false;
    for (final table in tables) {
      final key = 'share_last_${tripId}_$table';
      final last = prefs.getInt(key) ?? 0;
      final snap = await _trip(tripId)
          .collection(table)
          .where('updatedAt', isGreaterThan: last)
          .orderBy('updatedAt')
          .get(const GetOptions(source: Source.server));
      var upTo = last;
      for (final d in snap.docs) {
        try {
          final j = await BackupCrypto.decryptRowWith(k, d.data());
          final ms = (j['updatedAt'] as num).toInt();
          upTo = ms > upTo ? ms : upTo;
          if (await _upsert(table, j, role)) changed = true;
          _received[j['id'] as String] = ms;
        } catch (e) {
          debugPrint('shared pull $table: $e');
        }
      }
      if (upTo > last) await prefs.setInt(key, upTo);
    }
    if (changed) await _loadMembers(tripId);
  }

  /// Zapíše řádek z cloudu, když je novější než ten v telefonu. Vrací true při změně.
  Future<bool> _upsert(String table, Map<String, dynamic> j, String role) async {
    final db = _db!;
    final id = j['id'] as String;
    for (final k in _realKeys) {
      final v = j[k];
      if (v is int) j[k] = v.toDouble();
    }
    final remoteMs = (j['updatedAt'] as num).toInt();
    j['syncState'] = 'pending'; // do vlastní zálohy (Pro)
    Future<bool> exists(TableInfo t, String? value) async {
      if (value == null) return false;
      final r = await db.customSelect('SELECT 1 FROM ${t.actualTableName} WHERE id = ?',
          variables: [Variable(value)]).get();
      return r.isNotEmpty;
    }

    switch (table) {
      case 'trips':
        final local = await (db.select(db.trips)..where((x) => x.id.equals(id))).getSingleOrNull();
        if (local != null && local.updatedAt.millisecondsSinceEpoch >= remoteMs) return false;
        j['shareRole'] = role;
        await db.into(db.trips).insertOnConflictUpdate(Trip.fromJson(j));
      case 'places':
        final local = await (db.select(db.places)..where((x) => x.id.equals(id))).getSingleOrNull();
        if (local != null && local.updatedAt.millisecondsSinceEpoch >= remoteMs) return false;
        await db.into(db.places).insertOnConflictUpdate(Place.fromJson(j));
      case 'expenses':
        final local = await (db.select(db.expenses)..where((x) => x.id.equals(id))).getSingleOrNull();
        if (local != null && local.updatedAt.millisecondsSinceEpoch >= remoteMs) return false;
        if (!await exists(db.documents, j['receiptDocumentId'] as String?)) j['receiptDocumentId'] = null;
        j['receiptPath'] = local?.receiptPath; // účtenky se nesdílí
        await db.into(db.expenses).insertOnConflictUpdate(Expense.fromJson(j));
      case 'calendarEvents':
        final local =
            await (db.select(db.calendarEvents)..where((x) => x.id.equals(id))).getSingleOrNull();
        if (local != null && local.updatedAt.millisecondsSinceEpoch >= remoteMs) return false;
        // doklady se nesdílí – odkaz na cizí doklad zahodit, svůj ponechat
        if (!await exists(db.documents, j['documentId'] as String?)) j['documentId'] = local?.documentId;
        if (!await exists(db.places, j['placeId'] as String?)) j['placeId'] = null;
        if (!await exists(db.expenses, j['expenseId'] as String?)) j['expenseId'] = null;
        await db.into(db.calendarEvents).insertOnConflictUpdate(CalendarEvent.fromJson(j));
    }
    return true;
  }

  // ---------- odeslání ----------

  Future<List<Map<String, dynamic>>> _rowsOf(String tripId, String table, DateTime after) async {
    final db = _db!;
    final rows = switch (table) {
      'trips' => [
          for (final r in await (db.select(db.trips)
                ..where((x) => x.id.equals(tripId) & x.updatedAt.isBiggerThanValue(after)))
              .get())
            {...r.toJson(), 'shareRole': null, 'syncState': null}
        ],
      'places' => [
          for (final r in await (db.select(db.places)
                ..where((x) => x.tripId.equals(tripId) & x.updatedAt.isBiggerThanValue(after)))
              .get())
            {...r.toJson(), 'syncState': null}
        ],
      'expenses' => [
          for (final r in await (db.select(db.expenses)
                ..where((x) => x.tripId.equals(tripId) & x.updatedAt.isBiggerThanValue(after)))
              .get())
            {...r.toJson(), 'receiptPath': null, 'syncState': null}
        ],
      _ => [
          for (final r in await (db.select(db.calendarEvents)
                ..where((x) => x.tripId.equals(tripId) & x.updatedAt.isBiggerThanValue(after)))
              .get())
            {...r.toJson(), 'syncState': null}
        ],
    };
    return rows.where((r) => _received[r['id']] != r['updatedAt']).toList();
  }

  Future<void> pushAll() async {
    if (kDemo) return;
    final db = _db;
    if (db == null || myUid == null || _pushing) return;
    _pushing = true;
    try {
      for (final t in await (db.select(db.trips)..where((t) => t.shareRole.isNotNull())).get()) {
        await push(t.id);
      }
    } catch (e) {
      debugPrint('shared push: $e');
    } finally {
      _pushing = false;
    }
  }

  Future<void> push(String tripId) async {
    final k = await _key(tripId);
    if (k == null) return;
    final prefs = await _p;
    final wmKey = 'share_push_$tripId';
    final wm = DateTime.fromMillisecondsSinceEpoch(prefs.getInt(wmKey) ?? 0);
    var maxMs = wm.millisecondsSinceEpoch;
    var any = false;
    for (final table in tables) {
      final rows = await _rowsOf(tripId, table, wm);
      for (var i = 0; i < rows.length; i += 200) {
        final batch = _fs.batch();
        for (final r in rows.skip(i).take(200)) {
          batch.set(_trip(tripId).collection(table).doc(r['id'] as String),
              await BackupCrypto.encryptRowWith(k, r));
          final ms = r['updatedAt'] as int;
          if (ms > maxMs) maxMs = ms;
        }
        await batch.commit().timeout(_net);
        any = true;
      }
    }
    if (any) {
      await _trip(tripId).update({'rev': DateTime.now().millisecondsSinceEpoch});
      await prefs.setInt(wmKey, maxMs);
    }
  }

  // ---------- sdílení, pozvánky ----------

  /// Majitel (Pro): ze své cesty udělá společnou. Vrací kód pozvánky.
  Future<String> share(String tripId, String myName) async {
    final db = _db!, uid = myUid!;
    if (await _key(tripId) == null) {
      final raw = newTripKey();
      await _trip(tripId).set({'ownerUid': uid, 'rev': DateTime.now().millisecondsSinceEpoch}).timeout(_net);
      await _trip(tripId).collection('members').doc(uid).set({'name': myName, 'role': 'owner'}).timeout(_net);
      await _saveKey(tripId, raw, role: 'owner');
      await (db.update(db.trips)..where((x) => x.id.equals(tripId))).write(TripsCompanion(
          shareRole: const Value('owner'), updatedAt: Value(DateTime.now()), syncState: const Value('pending')));
      (await _p).remove('share_push_$tripId');
      await push(tripId);
      _attach(tripId);
    }
    return createInvite(tripId);
  }

  /// Nová pozvánka (platí 7 dní, kód může použít víc lidí).
  Future<String> createInvite(String tripId) async {
    final k = await _key(tripId);
    if (k == null) throw StateError('no-key');
    final code = newInviteCode();
    await _fs.collection('invites').doc(await inviteId(code)).set({
      'tripId': tripId,
      'inviterUid': myUid,
      'wrappedKey': await wrapTripKey(code, await k.extractBytes()),
      'expiresAt': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
    }).timeout(_net);
    return code;
  }

  /// Připojení kódem. Vrací id cesty, nebo vyhodí chybu ('invalid', 'expired').
  Future<String> join(String code, String myName) async {
    final uid = myUid!;
    final id = await inviteId(code);
    final inv = (await _fs.collection('invites').doc(id).get(const GetOptions(source: Source.server)).timeout(_net)).data();
    if (inv == null) throw StateError('invalid');
    if ((inv['expiresAt'] as num) < DateTime.now().millisecondsSinceEpoch) throw StateError('expired');
    final tripId = inv['tripId'] as String;
    final raw = await unwrapTripKey(code, inv['wrappedKey'] as String);
    await _trip(tripId).collection('members').doc(uid).set({'name': myName, 'role': 'member', 'invite': id}).timeout(_net);
    await _saveKey(tripId, raw, role: 'member');
    for (final t in tables) {
      (await _p).remove('share_last_${tripId}_$t');
    }
    await pull(tripId);
    // to, co už v telefonu je, se znovu neposílá
    (await _p).setInt('share_push_$tripId', DateTime.now().millisecondsSinceEpoch);
    _attach(tripId);
    return tripId;
  }

  Future<void> removeMember(String tripId, String uid) async {
    await _trip(tripId).collection('members').doc(uid).delete();
    await _loadMembers(tripId);
  }

  /// Účastník: odejít ze společné cesty (cesta zmizí z telefonu, ostatním zůstane).
  Future<void> leave(String tripId) async {
    final db = _db!, uid = myUid!;
    await _subs.remove(tripId)?.cancel();
    await _trip(tripId).collection('members').doc(uid).delete();
    await _fs.collection('users').doc(uid).collection('shared_trips').doc(tripId).delete();
    await _storage.delete(key: 'trip_key_$tripId');
    _keys.remove(tripId);
    final now = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.trips)..where((x) => x.id.equals(tripId))).write(TripsCompanion(
          shareRole: const Value(null), deletedAt: Value(now), updatedAt: Value(now), syncState: const Value('pending')));
      for (final t in <TableInfo<Table, dynamic>>[db.places, db.expenses, db.calendarEvents]) {
        await db.customUpdate(
            "UPDATE ${t.actualTableName} SET deleted_at = ?, updated_at = ?, sync_state = 'pending' WHERE trip_id = ?",
            variables: [Variable(now), Variable(now), Variable(tripId)],
            updates: {t});
      }
    });
    notifyListeners();
  }

  /// Majitel: zrušit sdílení (ostatním cesta zůstane jako jejich kopie).
  Future<void> stopSharing(String tripId) async {
    final db = _db!, uid = myUid!;
    await _subs.remove(tripId)?.cancel();
    final ms = await _trip(tripId).collection('members').get();
    for (final d in ms.docs) {
      if (d.id != uid) await d.reference.delete();
    }
    await _trip(tripId).delete();
    await _trip(tripId).collection('members').doc(uid).delete();
    await _fs.collection('users').doc(uid).collection('shared_trips').doc(tripId).delete();
    await (db.update(db.trips)..where((x) => x.id.equals(tripId))).write(TripsCompanion(
        shareRole: const Value(null), updatedAt: Value(DateTime.now()), syncState: const Value('pending')));
    members.remove(tripId);
    notifyListeners();
  }
}
