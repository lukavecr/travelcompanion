import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../../core/map_tiles.dart';
import '../../data/database.dart';
import 'tracker_service.dart';
import '../../l10n/tr.dart';

final tracksProvider = StreamProvider.autoDispose<List<Track>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.tracks)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
      .watch();
});

final trackProvider = StreamProvider.autoDispose.family<Track?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.tracks)..where((t) => t.id.equals(id))).watchSingleOrNull();
});

/// Karta se stavem záznamu a tlačítkem Start/Stop (seznam tras i mapa).
class RecordCard extends StatefulWidget {
  const RecordCard({super.key});

  @override
  State<RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  final _tracker = TrackerService.instance;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tracker.addListener(_changed);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_tracker.recording && mounted) setState(() {});
    });
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tracker.removeListener(_changed);
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_tracker.recording) {
      await _tracker.stop();
      return;
    }
    final err = await _tracker.start();
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = _tracker.recording;
    final dur = rec ? DateTime.now().difference(_tracker.startedAt!) : Duration.zero;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(rec ? Icons.fiber_manual_record : Icons.route,
                color: rec ? Colors.redAccent : scheme.primary, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: rec
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(fmtDistance(_tracker.distance),
                            style: Theme.of(context).textTheme.headlineSmall),
                        Text('${fmtDuration(dur)} · ${tr('{n} bodů', {'n': _tracker.points.length})}'),
                      ],
                    )
                  : Text(tr('Zaznamenej, kudy jdeš: trasa na mapě, vzdálenost a čas. Funguje i se zhasnutým displejem.')),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              style: rec ? FilledButton.styleFrom(backgroundColor: Colors.redAccent) : null,
              onPressed: _toggle,
              icon: Icon(rec ? Icons.stop : Icons.play_arrow),
              label: Text(rec ? tr('Stop') : tr('Start')),
            ),
          ],
        ),
      ),
    );
  }
}

class TracksScreen extends ConsumerWidget {
  const TracksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Trasy'))),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const RecordCard(),
          const SizedBox(height: 8),
          ...tracks.when(
            loading: () => [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [Text(tr('Chyba: {e}', {'e': e}))],
            data: (list) {
              final done = list.where((t) => t.endedAt != null).toList();
              if (done.isEmpty) {
                return [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(tr('Zatím tu nejsou žádné trasy.'), textAlign: TextAlign.center),
                  )
                ];
              }
              final total = done.fold<double>(0, (s, t) => s + t.distanceM);
              return [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Text(tr('Celkem {d}', {'d': fmtDistance(total)}),
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                for (final t in done)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.timeline),
                      title: Text(t.name),
                      subtitle: Text(
                          '${fmtDistance(t.distanceM)} · ${fmtDuration(t.endedAt!.difference(t.startedAt))}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/map/tracks/${t.id}'),
                    ),
                  ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class TrackDetailScreen extends ConsumerStatefulWidget {
  const TrackDetailScreen({super.key, required this.trackId});
  final String trackId;

  @override
  ConsumerState<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen> {
  final _shotKey = GlobalKey();
  bool _exporting = false; // při exportu se do mapy přidá název, údaje a logo

  Future<void> _rename(AppDatabase db, Track t) async {
    final c = TextEditingController(text: t.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Název trasy')),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Zrušit'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(tr('Uložit'))),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await (db.update(db.tracks)..where((x) => x.id.equals(t.id))).write(TracksCompanion(
      name: Value(name),
      updatedAt: Value(DateTime.now()),
      syncState: const Value('pending'),
    ));
  }

  Future<void> _gpx(Track t) async {
    final dir = await getTemporaryDirectory();
    final f = File(p.join(dir.path, '${_safe(t.name)}.gpx'));
    await f.writeAsString(buildGpx(t));
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'application/gpx+xml')], subject: t.name));
  }

  String _safe(String s) => s.replaceAll(RegExp(r'[^\w\- ]+'), '_');

  /// Obrázek trasy: mapa tak, jak ji uživatel přiblížil, + název, datum, údaje a logo aplikace.
  Future<void> _image(Track t) async {
    setState(() => _exporting = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 250)); // dlaždice mapy pod popisky
      final boundary = _shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final f = File(p.join(dir.path, '${_safe(t.name)}.png'));
      await f.writeAsBytes(png!.buffer.asUint8List());
      if (!mounted) return;
      setState(() => _exporting = false);
      await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'image/png')], text: t.name));
    } finally {
      if (mounted && _exporting) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final track = ref.watch(trackProvider(widget.trackId)).value;
    if (track == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final pts = [for (final x in decodePoints(track.points)) LatLng(x.$1, x.$2)];
    final dur = (track.endedAt ?? DateTime.now()).difference(track.startedAt);
    final hours = dur.inSeconds / 3600;
    final speed = hours > 0 ? track.distanceM / 1000 / hours : 0.0;
    final when = '${fmtDate(track.startedAt)} ${fmtTime(track.startedAt.hour * 60 + track.startedAt.minute)}';
    final stats = [
      (tr('Vzdálenost'), fmtDistance(track.distanceM)),
      (tr('Čas'), fmtDuration(dur)),
      (tr('Průměr'), '${fmtMoney(speed, 1)} km/h'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(track.name),
        actions: [
          if (pts.length >= 2)
            IconButton(
              tooltip: tr('Sdílet jako obrázek'),
              icon: const Icon(Icons.ios_share),
              onPressed: _exporting ? null : () => _image(track),
            ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'rename') await _rename(db, track);
              if (v == 'image') await _image(track);
              if (v == 'gpx') await _gpx(track);
              if (v == 'delete' && context.mounted && await confirm(context, tr('Smazat trasu?'))) {
                await (db.update(db.tracks)..where((x) => x.id.equals(track.id))).write(TracksCompanion(
                  deletedAt: Value(DateTime.now()),
                  updatedAt: Value(DateTime.now()),
                  syncState: const Value('pending'),
                ));
                if (context.mounted) context.pop();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'rename', child: Text(tr('Přejmenovat'))),
              if (pts.length >= 2) PopupMenuItem(value: 'image', child: Text(tr('Sdílet jako obrázek'))),
              PopupMenuItem(value: 'gpx', child: Text(tr('Sdílet jako GPX'))),
              PopupMenuItem(value: 'delete', child: Text(tr('Smazat'))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [for (final (l, v) in stats) _Stat(l, v)],
            ),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(when)),
          Expanded(
            child: pts.length < 2
                ? Center(child: Text(tr('Trasa nemá dost bodů.')))
                : RepaintBoundary(
                    key: _shotKey,
                    child: Stack(
                      children: [
                        FlutterMap(
                          options: MapOptions(
                            initialCameraFit: CameraFit.coordinates(
                                coordinates: pts, padding: const EdgeInsets.all(40), maxZoom: 17),
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            const MapTiles(),
                            PolylineLayer(polylines: [
                              Polyline(points: pts, strokeWidth: 5, color: const Color(0xFFE5484D)),
                            ]),
                            MarkerLayer(markers: [
                              Marker(point: pts.first, width: 18, height: 18, child: const _Dot(Color(0xFF30A46C))),
                              Marker(point: pts.last, width: 18, height: 18, child: const _Dot(Color(0xFFE5484D))),
                            ]),
                            if (!_exporting) const MapAttribution(),
                          ],
                        ),
                        if (_exporting) _ShareOverlay(title: track.name, when: when, stats: stats),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Popisky na sdíleném obrázku trasy: název a datum nahoře, údaje a logo dole.
class _ShareOverlay extends StatelessWidget {
  const _ShareOverlay({required this.title, required this.when, required this.stats});
  final String title;
  final String when;
  final List<(String, String)> stats;

  @override
  Widget build(BuildContext context) {
    const fg = Color(0xFFE4F1ED);
    const muted = Color(0xFF93AEA7);
    return Positioned.fill(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xEE0B1412), Color(0x000B1412)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: fg, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                if (!title.contains(when)) Text(when, style: const TextStyle(color: muted, fontSize: 14)),
              ],
            ),
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xEE0B1412),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x552DD4A7)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final (l, v) in stats)
                      Column(children: [
                        Text(v, style: const TextStyle(color: fg, fontSize: 20, fontWeight: FontWeight.w800)),
                        Text(l, style: const TextStyle(color: muted, fontSize: 12)),
                      ]),
                  ],
                ),
                const Divider(color: Color(0x332DD4A7), height: 20),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset('assets/brand/logo.png', width: 26, height: 26),
                    ),
                    const SizedBox(width: 8),
                    const Text('Comes Viae',
                        style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    const Text('© OpenStreetMap', style: TextStyle(color: muted, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
      );
}
