import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/database.dart';
import 'vault_crypto.dart';
import 'vault_types.dart';

/// Odšifrovaná položka Vaultu (jen v paměti).
class VaultEntry {
  VaultEntry({
    required this.id,
    required this.type,
    required this.fields,
    required this.photoIds,
    this.updatedAt,
  });
  final String id;
  final String type;
  final Map<String, String> fields;
  final List<String> photoIds;
  final DateTime? updatedAt;

  VaultType get def => vaultType(type);

  String get title {
    final f = def.titleField;
    final t = f == null ? null : fields[f]?.trim();
    return (t == null || t.isEmpty) ? def.label : t;
  }

  DateTime? get expiresAt => parseIsoDate(fields[def.expiryField]);
}

DateTime? parseIsoDate(String? s) => (s == null || s.isEmpty) ? null : DateTime.tryParse(s);
String toIsoDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// klíče v SharedPreferences (začínají „vault_“, takže je „Smazat všechna data“ nechá být)
const prefUploadPending = 'vault_photos_upload';
const prefRemoteDelete = 'vault_photos_delete';

class VaultRepository {
  VaultRepository(this.db);
  final AppDatabase db;
  final _keys = VaultKeys.instance;
  static const _uuid = Uuid();

  Stream<List<VaultItem>> watchRows() => (db.select(db.vaultItems)
        ..where((v) => v.deletedAt.isNull())
        ..orderBy([(v) => OrderingTerm.asc(v.type)]))
      .watch();

  Future<VaultEntry> decrypt(VaultItem row) async {
    final j = await _keys.decryptJson(row.encryptedBlob);
    return VaultEntry(
      id: row.id,
      type: row.type,
      fields: Map<String, String>.from(j['fields'] as Map? ?? const {}),
      photoIds: List<String>.from(j['photos'] as List? ?? const []),
      updatedAt: row.updatedAt,
    );
  }

  Future<String> save({
    String? id,
    required String type,
    required Map<String, String> fields,
    required List<String> photoIds,
  }) async {
    final rowId = id ?? _uuid.v4();
    final blob = await _keys.encryptJson({'fields': fields, 'photos': photoIds});
    final entry = VaultEntry(id: rowId, type: type, fields: fields, photoIds: photoIds);
    await db.into(db.vaultItems).insertOnConflictUpdate(VaultItemsCompanion.insert(
          id: rowId,
          type: type,
          encryptedBlob: blob,
          expiresAt: Value(entry.expiresAt),
          updatedAt: Value(DateTime.now()),
          syncState: const Value('pending'),
        ));
    return rowId;
  }

  /// Smaže jednu položku (soft delete kvůli záloze) i její fotky.
  Future<void> delete(VaultEntry e) async {
    await (db.update(db.vaultItems)..where((v) => v.id.equals(e.id))).write(
      VaultItemsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncState: const Value('pending'),
      ),
    );
    for (final pid in e.photoIds) {
      await deletePhoto(pid);
    }
  }

  // ---------- fotky (šifrované soubory) ----------
  static Future<Directory> photoDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'vault'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<File> photoFile(String id) async => File(p.join((await photoDir()).path, '$id.bin'));

  /// Zmenší fotku (do ~0,6 MB kvůli záloze), zašifruje a uloží. Vrací id fotky.
  Future<String?> addPhoto(String path) async {
    var quality = 80;
    var size = 2000;
    Uint8List? jpg;
    for (var i = 0; i < 5; i++) {
      jpg = await FlutterImageCompress.compressWithFile(path,
          minWidth: size, minHeight: size, quality: quality, format: CompressFormat.jpeg);
      if (jpg == null) return null;
      if (jpg.length <= 600000) break;
      quality -= 10;
      size = (size * 0.8).round();
    }
    final id = _uuid.v4();
    await (await photoFile(id)).writeAsBytes(await _keys.encryptBytes(jpg!));
    await _addToList(prefUploadPending, id);
    try {
      await File(path).delete(); // nešifrovaná kopie z fotoaparátu (jen pokud je v cache aplikace)
    } catch (_) {}
    return id;
  }

  /// Odšifrovaná fotka; když v telefonu chybí, stáhne ji ze zálohy.
  Future<Uint8List?> loadPhoto(String id, {Future<Uint8List?> Function(String id)? download}) async {
    final f = await photoFile(id);
    Uint8List? enc;
    if (await f.exists()) {
      enc = await f.readAsBytes();
    } else if (download != null) {
      enc = await download(id);
      if (enc != null) await f.writeAsBytes(enc);
    }
    if (enc == null) return null;
    return _keys.decryptBytes(enc);
  }

  Future<void> deletePhoto(String id) async {
    try {
      await (await photoFile(id)).delete();
    } catch (_) {}
    await _removeFromList(prefUploadPending, id);
    await _addToList(prefRemoteDelete, id);
  }

  static Future<void> _addToList(String key, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final l = prefs.getStringList(key) ?? [];
    if (!l.contains(id)) await prefs.setStringList(key, [...l, id]);
  }

  static Future<void> _removeFromList(String key, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final l = prefs.getStringList(key) ?? [];
    if (l.contains(id)) await prefs.setStringList(key, l.where((x) => x != id).toList());
  }
}

final vaultRepositoryProvider =
    Provider((ref) => VaultRepository(ref.watch(databaseProvider)));

/// Položky s datem konce platnosti (pro notifikace; nepotřebuje odemčený Vault).
final vaultExpiryProvider = StreamProvider<List<VaultItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.vaultItems)
        ..where((v) => v.deletedAt.isNull() & v.expiresAt.isNotNull()))
      .watch();
});

final vaultRowsProvider = StreamProvider.autoDispose<List<VaultItem>>(
    (ref) => ref.watch(vaultRepositoryProvider).watchRows());
