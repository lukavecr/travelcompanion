import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

/// Offline mapy: dlaždice OpenFreeMap stažené pro vybrané oblasti
/// (`app_support/offline_map/tiles/z/x/y.pbf`) a seznam oblastí (`regions.json`).
/// Mapa nejdřív hledá dlaždici v telefonu, až pak na internetu.

const offlineMaxZoom = 14; // OpenFreeMap má data do z14, víc se jen zvětšuje
const maxTilesPerRegion = 25000;
const avgTileBytes = 50000; // odhad pro uživatele (město ~60–130 kB, venkov ~10 kB)

Future<Directory> offlineDir() async {
  final d = Directory(p.join((await getApplicationSupportDirectory()).path, 'offline_map'));
  if (!await d.exists()) await d.create(recursive: true);
  return d;
}

/// Oblast na mapě (západ, jih, východ, sever) ve stupních.
class Bbox {
  const Bbox(this.west, this.south, this.east, this.north);
  final double west, south, east, north;

  Map<String, double> toJson() => {'w': west, 's': south, 'e': east, 'n': north};
  factory Bbox.fromJson(Map j) => Bbox((j['w'] as num).toDouble(), (j['s'] as num).toDouble(),
      (j['e'] as num).toDouble(), (j['n'] as num).toDouble());
}

int _lon2x(double lon, int z) => ((lon + 180) / 360 * (1 << z)).floor().clamp(0, (1 << z) - 1);
int _lat2y(double lat, int z) {
  final r = lat.clamp(-85.0511, 85.0511) * math.pi / 180;
  final y = (1 - math.log(math.tan(r) + 1 / math.cos(r)) / math.pi) / 2 * (1 << z);
  return y.floor().clamp(0, (1 << z) - 1);
}

/// Počet dlaždic oblasti pro úrovně 0…[maxZoom].
int tileCount(Bbox b, int maxZoom) {
  var n = 0;
  for (var z = 0; z <= maxZoom; z++) {
    n += (_lon2x(b.east, z) - _lon2x(b.west, z) + 1) * (_lat2y(b.south, z) - _lat2y(b.north, z) + 1);
  }
  return n;
}

Iterable<(int, int, int)> tilesOf(Bbox b, int maxZoom) sync* {
  for (var z = 0; z <= maxZoom; z++) {
    for (var x = _lon2x(b.west, z); x <= _lon2x(b.east, z); x++) {
      for (var y = _lat2y(b.north, z); y <= _lat2y(b.south, z); y++) {
        yield (z, x, y);
      }
    }
  }
}

class OfflineRegion {
  OfflineRegion({
    required this.id,
    required this.name,
    required this.bbox,
    required this.maxZoom,
    required this.createdAt,
    this.tiles = 0,
    this.bytes = 0,
    this.done = false,
  });
  final String id;
  String name;
  final Bbox bbox;
  final int maxZoom;
  final DateTime createdAt;
  int tiles;
  int bytes;
  bool done;

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'bbox': bbox.toJson(),
        'maxZoom': maxZoom,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'tiles': tiles,
        'bytes': bytes,
        'done': done,
      };
  factory OfflineRegion.fromJson(Map j) => OfflineRegion(
        id: j['id'] as String,
        name: j['name'] as String,
        bbox: Bbox.fromJson(j['bbox'] as Map),
        maxZoom: j['maxZoom'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(j['createdAt'] as int),
        tiles: j['tiles'] as int? ?? 0,
        bytes: j['bytes'] as int? ?? 0,
        done: j['done'] as bool? ?? false,
      );
}

/// Správa offline oblastí a jejich stahování (běží, dokud je aplikace otevřená).
class OfflineMaps extends ChangeNotifier {
  OfflineMaps._();
  static final instance = OfflineMaps._();

  List<OfflineRegion> regions = [];
  String? urlTemplate; // aktuální adresa dlaždic OpenFreeMap (z TileJSON stylu)
  String? downloadingId;
  int progress = 0, total = 0, failed = 0;
  bool _cancel = false;
  bool _loaded = false;

  Future<File> get _regionsFile async => File(p.join((await offlineDir()).path, 'regions.json'));
  Future<String> get _tilesRoot async => p.join((await offlineDir()).path, 'tiles');

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final f = await _regionsFile;
      if (await f.exists()) {
        regions = [for (final r in jsonDecode(await f.readAsString()) as List) OfflineRegion.fromJson(r as Map)];
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async =>
      (await _regionsFile).writeAsString(jsonEncode([for (final r in regions) r.toJson()]));

  int get totalBytes => regions.fold(0, (s, r) => s + r.bytes);

  Future<File> _tileFile(int z, int x, int y) async => File(p.join(await _tilesRoot, '$z', '$x', '$y.pbf'));

  /// Dlaždice z telefonu (nebo null).
  Future<Uint8List?> read(int z, int x, int y) async {
    try {
      final f = await _tileFile(z, x, y);
      if (await f.exists()) return await f.readAsBytes();
    } catch (_) {}
    return null;
  }

  Future<OfflineRegion> add(String name, Bbox bbox, int maxZoom) async {
    final r = OfflineRegion(id: const Uuid().v4(), name: name, bbox: bbox, maxZoom: maxZoom, createdAt: DateTime.now());
    regions.add(r);
    await _save();
    notifyListeners();
    unawaited(download(r));
    return r;
  }

  /// Stáhne chybějící dlaždice oblasti (4 souběžně). Lze přerušit a později pokračovat.
  Future<void> download(OfflineRegion r) async {
    if (downloadingId != null) return;
    final template = urlTemplate;
    if (template == null) {
      failed = -1; // styl mapy ještě není načtený (bez internetu)
      notifyListeners();
      return;
    }
    downloadingId = r.id;
    _cancel = false;
    progress = 0;
    failed = 0;
    total = tileCount(r.bbox, r.maxZoom);
    notifyListeners();

    final client = http.Client();
    final queue = tilesOf(r.bbox, r.maxZoom).iterator;
    var bytes = 0;
    var lastNotify = DateTime.now();

    Future<void> worker() async {
      while (!_cancel) {
        (int, int, int) t;
        if (!queue.moveNext()) return;
        t = queue.current;
        final f = await _tileFile(t.$1, t.$2, t.$3);
        try {
          if (await f.exists()) {
            bytes += await f.length();
          } else {
            final url = template
                .replaceAll('{z}', '${t.$1}')
                .replaceAll('{x}', '${t.$2}')
                .replaceAll('{y}', '${t.$3}');
            final res = await client
                .get(Uri.parse(url), headers: {'User-Agent': 'TravelCompanion/1.0 (lrtechcz@gmail.com)'})
                .timeout(const Duration(seconds: 20));
            if (res.statusCode == 200) {
              await f.parent.create(recursive: true);
              await f.writeAsBytes(res.bodyBytes);
              bytes += res.bodyBytes.length;
            } else if (res.statusCode != 204 && res.statusCode != 404) {
              failed++;
            }
          }
        } catch (_) {
          failed++;
        }
        progress++;
        if (DateTime.now().difference(lastNotify).inMilliseconds > 300) {
          lastNotify = DateTime.now();
          r.bytes = bytes;
          notifyListeners();
        }
      }
    }

    try {
      await Future.wait([for (var i = 0; i < 4; i++) worker()]);
    } finally {
      client.close();
    }
    r.tiles = progress;
    r.bytes = bytes;
    r.done = !_cancel && failed == 0;
    downloadingId = null;
    await _save();
    notifyListeners();
  }

  void cancel() => _cancel = true;

  Future<void> rename(OfflineRegion r, String name) async {
    r.name = name;
    await _save();
    notifyListeners();
  }

  /// Smaže oblast a dlaždice, které nepatří žádné jiné oblasti.
  Future<void> remove(OfflineRegion r) async {
    if (downloadingId == r.id) {
      cancel();
      while (downloadingId != null) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    regions.removeWhere((x) => x.id == r.id);
    await _save();
    notifyListeners();
    final keep = <String>{
      for (final o in regions)
        for (final t in tilesOf(o.bbox, o.maxZoom)) '${t.$1}/${t.$2}/${t.$3}'
    };
    for (final t in tilesOf(r.bbox, r.maxZoom)) {
      if (keep.contains('${t.$1}/${t.$2}/${t.$3}')) continue;
      try {
        await (await _tileFile(t.$1, t.$2, t.$3)).delete();
      } catch (_) {}
    }
  }
}

/// Dlaždice nejdřív z offline oblastí, jinak z internetu.
class OfflineFirstTileProvider extends VectorTileProvider {
  OfflineFirstTileProvider(this.delegate);
  final VectorTileProvider delegate;

  @override
  int get maximumZoom => delegate.maximumZoom;
  @override
  int get minimumZoom => delegate.minimumZoom;
  @override
  TileOffset get tileOffset => delegate.tileOffset;

  @override
  Future<Uint8List> provide(TileIdentity tile) async {
    final local = await OfflineMaps.instance.read(tile.z, tile.x, tile.y);
    if (local != null) return local;
    return delegate.provide(tile);
  }
}
