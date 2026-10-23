import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../../core/geocode.dart';
import '../../core/map_tiles.dart';
import '../../data/database.dart';
import '../pro/paywall.dart';
import 'offline_tiles.dart';
import '../../l10n/tr.dart';

String fmtBytes(int b) => b < 1024 * 1024
    ? '${(b / 1024).round()} kB'
    : b < 1024 * 1024 * 1024
        ? '${fmtMoney(b / 1024 / 1024)} MB'
        : '${fmtMoney(b / 1024 / 1024 / 1024, 1)} GB';

/// Seznam stažených oblastí, průběh stahování, mazání.
class OfflineMapsScreen extends ConsumerWidget {
  const OfflineMapsScreen({super.key, this.center, this.zoom});
  final LatLng? center;
  final double? zoom;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    if (!await ensureCanAdd(context, ref.read(databaseProvider), ProLimit.offlineMap)) return;
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => RegionPickerScreen(center: center, zoom: zoom),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final om = OfflineMaps.instance;
    return ListenableBuilder(
      listenable: om,
      builder: (context, _) {
        final theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(title: Text(tr('Offline mapy'))),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: om.downloadingId != null ? null : () => _add(context, ref),
            icon: const Icon(Icons.download),
            label: Text(tr('Stáhnout oblast')),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            children: [
              Text(
                tr('Stažená mapa funguje i bez signálu. Vyber si výřez – město nebo region – a stáhni ho, ideálně přes Wi-Fi.'),
              ),
              if (om.failed == -1 && om.downloadingId == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(tr('Mapa se ještě nenačetla z internetu. Otevři jednou záložku Mapa s připojením.'),
                      style: TextStyle(color: theme.colorScheme.error)),
                ),
              const SizedBox(height: 12),
              if (om.regions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(tr('Zatím nemáš staženou žádnou oblast.'), textAlign: TextAlign.center),
                ),
              for (final r in om.regions)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(r.done ? Icons.offline_pin : Icons.map_outlined,
                                color: r.done ? Colors.green : null),
                            const SizedBox(width: 12),
                            Expanded(child: Text(r.name, style: theme.textTheme.titleMedium)),
                            PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'resume') om.download(r);
                                if (v == 'rename') {
                                  final n = await _askName(context, r.name);
                                  if (n != null) om.rename(r, n);
                                }
                                if (v == 'delete' &&
                                    context.mounted &&
                                    await confirm(context, tr('Smazat offline oblast „{n}“?', {'n': r.name}))) {
                                  await om.remove(r);
                                }
                              },
                              itemBuilder: (_) => [
                                if (!r.done && om.downloadingId == null)
                                  PopupMenuItem(value: 'resume', child: Text(tr('Dokončit stahování'))),
                                PopupMenuItem(value: 'rename', child: Text(tr('Přejmenovat'))),
                                PopupMenuItem(value: 'delete', child: Text(tr('Smazat'))),
                              ],
                            ),
                          ],
                        ),
                        if (om.downloadingId == r.id) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(value: om.total == 0 ? null : om.progress / om.total),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(tr('Stahuji {a} / {b} · {mb}', {
                                  'a': om.progress,
                                  'b': om.total,
                                  'mb': fmtBytes(r.bytes),
                                })),
                              ),
                              TextButton(onPressed: om.cancel, child: Text(tr('Přerušit'))),
                            ],
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(left: 36, top: 2),
                            child: Text(r.done
                                ? '${fmtBytes(r.bytes)} · ${fmtDate(r.createdAt)}'
                                : tr('Nedokončeno – v menu „Dokončit stahování“')),
                          ),
                      ],
                    ),
                  ),
                ),
              if (om.regions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(tr('Celkem v telefonu: {mb}', {'mb': fmtBytes(om.totalBytes)}),
                      style: theme.textTheme.bodySmall),
                ),
            ],
          ),
        );
      },
    );
  }
}

Future<String?> _askName(BuildContext context, String initial) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('Název oblasti')),
      content: TextField(controller: c, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('Zrušit'))),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, c.text.trim().isEmpty ? null : c.text.trim()),
          child: Text(tr('Uložit')),
        ),
      ],
    ),
  );
}

/// Výběr oblasti: posuň a přibliž mapu, stáhne se, co je v rámečku.
class RegionPickerScreen extends StatefulWidget {
  const RegionPickerScreen({super.key, this.center, this.zoom});
  final LatLng? center;
  final double? zoom;

  @override
  State<RegionPickerScreen> createState() => _RegionPickerScreenState();
}

class _RegionPickerScreenState extends State<RegionPickerScreen> {
  final _map = MapController();
  final _frameKey = GlobalKey();
  final _mapKey = GlobalKey();
  int _maxZoom = offlineMaxZoom;
  Bbox? _bbox;

  /// Rámeček na obrazovce → souřadnice.
  void _update() {
    final frame = _frameKey.currentContext?.findRenderObject() as RenderBox?;
    final map = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (frame == null || map == null) return;
    final tl = map.globalToLocal(frame.localToGlobal(Offset.zero));
    final br = tl + Offset(frame.size.width, frame.size.height);
    final cam = _map.camera;
    final a = cam.screenOffsetToLatLng(tl), b = cam.screenOffsetToLatLng(br);
    setState(() => _bbox = Bbox(a.longitude, b.latitude, b.longitude, a.latitude));
  }

  Future<void> _download() async {
    final b = _bbox;
    if (b == null) return;
    final c = LatLng((b.north + b.south) / 2, (b.east + b.west) / 2);
    final suggested = await reverseName(c.latitude, c.longitude) ?? tr('Moje oblast');
    if (!mounted) return;
    final name = await _askName(context, suggested);
    if (name == null || !mounted) return;
    await OfflineMaps.instance.add(name, b, _maxZoom);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final b = _bbox;
    final n = b == null ? 0 : tileCount(b, _maxZoom);
    final tooBig = n > maxTilesPerRegion;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(tr('Vyber oblast'))),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  key: _mapKey,
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: widget.center ?? const LatLng(50.08, 14.42),
                    initialZoom: widget.zoom ?? 11,
                    minZoom: 3,
                    maxZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: () => WidgetsBinding.instance.addPostFrameCallback((_) => _update()),
                    onPositionChanged: (_, _) => _update(),
                  ),
                  children: const [MapTiles(), MapAttribution()],
                ),
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Container(
                      key: _frameKey,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.primary, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(tr('Podrobnost'), style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  SegmentedButton<int>(
                    segments: [
                      ButtonSegment(value: 14, label: Text(tr('Ulice'))),
                      ButtonSegment(value: 12, label: Text(tr('Silnice'))),
                      ButtonSegment(value: 10, label: Text(tr('Přehled'))),
                    ],
                    selected: {_maxZoom},
                    onSelectionChanged: (s) => setState(() => _maxZoom = s.first),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tooBig
                        ? tr('Oblast je moc velká ({n} dlaždic). Přibliž mapu nebo zvol menší podrobnost.', {'n': n})
                        : tr('Asi {mb} ({n} dlaždic)', {'mb': fmtBytes(n * avgTileBytes), 'n': n}),
                    style: tooBig ? TextStyle(color: theme.colorScheme.error) : null,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: b == null || tooBig ? null : _download,
                    icon: const Icon(Icons.download),
                    label: Text(tr('Stáhnout tuto oblast')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
