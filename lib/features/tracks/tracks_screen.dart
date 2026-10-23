import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
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

class TrackDetailScreen extends ConsumerWidget {
  const TrackDetailScreen({super.key, required this.trackId});
  final String trackId;

  Future<void> _rename(BuildContext context, AppDatabase db, Track t) async {
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
    final safe = t.name.replaceAll(RegExp(r'[^\w\- ]+'), '_');
    final f = File(p.join(dir.path, '$safe.gpx'));
    await f.writeAsString(buildGpx(t));
    await SharePlus.instance.share(ShareParams(files: [XFile(f.path, mimeType: 'application/gpx+xml')], subject: t.name));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final track = ref.watch(trackProvider(trackId)).value;
    if (track == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    final pts = [for (final x in decodePoints(track.points)) LatLng(x.$1, x.$2)];
    final dur = (track.endedAt ?? DateTime.now()).difference(track.startedAt);
    final hours = dur.inSeconds / 3600;
    final speed = hours > 0 ? track.distanceM / 1000 / hours : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(track.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'rename') await _rename(context, db, track);
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
              children: [
                _Stat(tr('Vzdálenost'), fmtDistance(track.distanceM)),
                _Stat(tr('Čas'), fmtDuration(dur)),
                _Stat(tr('Průměr'), '${fmtMoney(speed, 1)} km/h'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
                '${fmtDate(track.startedAt)} ${fmtTime(track.startedAt.hour * 60 + track.startedAt.minute)}'),
          ),
          Expanded(
            child: pts.length < 2
                ? Center(child: Text(tr('Trasa nemá dost bodů.')))
                : FlutterMap(
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
                      const MapAttribution(),
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
