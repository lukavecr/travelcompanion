import 'dart:async';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/map_tiles.dart';
import '../../core/plus_code.dart';
import '../../data/database.dart';
import '../places/locate_place_screen.dart';
import '../places/open_in_maps.dart';
import '../places/place_types.dart';
import '../trips/trip_repository.dart';

bool hasCoords(Place p) => !(p.lat == 0 && p.lng == 0); // 0,0 = neznámé

Color placeColor(String type) {
  switch (type) {
    case 'hotel':
      return const Color(0xFF9B7BE8);
    case 'attraction':
      return const Color(0xFF2EC4A0);
    case 'restaurant':
      return const Color(0xFFF2A33A);
    case 'transport':
      return const Color(0xFF4AA3F0);
    default:
      return const Color(0xFFE5677A);
  }
}

/// Záložka Mapa: místa ze všech cest na OpenStreetMap (bez Google Maps SDK).
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _map = MapController();
  bool _ready = false;
  String? _tripId; // null = všechny cesty
  List<LatLng> _points = const [];
  LatLng? _me; // moje aktuální poloha
  double? _meAccuracy;
  StreamSubscription<Position>? _meSub;

  @override
  void dispose() {
    _meSub?.cancel();
    super.dispose();
  }

  void _snack(String text) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(text)));

  /// Zapne sledování polohy (GPS v telefonu, zdarma) a přesune mapu na mě.
  Future<void> _showMe() async {
    if (_me != null) {
      _map.move(_me!, math.max(_map.camera.zoom, 15));
      return;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      _snack('Zapni v telefonu Polohu (GPS).');
      await Geolocator.openLocationSettings();
      return;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      _snack('Bez povolení polohy tě na mapě neukážu.');
      return;
    }
    if (perm == LocationPermission.deniedForever) {
      _snack('Poloha je pro aplikaci zakázaná – povol ji v Nastavení.');
      await Geolocator.openAppSettings();
      return;
    }
    // rychle poslední známá poloha, pak průběžné upřesňování
    final last = await Geolocator.getLastKnownPosition();
    if (last != null && mounted) _onPosition(last, move: true);
    var first = true; // první čerstvá poloha z GPS → přesunout (uložená může být stará)
    _meSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((p) {
      _onPosition(p, move: first);
      first = false;
    }, onError: (_) {});
  }

  void _onPosition(Position p, {bool move = false}) {
    if (!mounted) return;
    setState(() {
      _me = LatLng(p.latitude, p.longitude);
      _meAccuracy = p.accuracy;
    });
    if (move && _ready) _map.move(_me!, 15);
  }

  /// Odkaz zkopírovaný v Google Mapách (Sdílet → Kopírovat) → stejná obrazovka jako sdílení.
  /// Na iPhonu je to jediná cesta (sdílení do aplikace chce placený účet Apple).
  Future<void> _pasteLink() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim() ?? '';
    if (!mounted) return;
    final looksLikePlace = text.contains('http') ||
        findPlusCode(text) != null ||
        RegExp(r'-?\d{1,3}\.\d+,\s*-?\d{1,3}\.\d+').hasMatch(text);
    if (!looksLikePlace) {
      _snack('Ve schránce není odkaz na místo. V Google Mapách dej Sdílet → Kopírovat odkaz.');
      return;
    }
    context.push('/share', extra: text);
  }

  /// Uložení libovolného bodu (moje poloha / dlouhé podržení) přes obrazovku sdílení.
  void _savePoint(LatLng p, String name) {
    final q = '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}';
    context.push('/share',
        extra: '$name\nhttps://www.google.com/maps/search/?api=1&query=$q');
  }

  void _pointSheet(LatLng p, {required bool me}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(me ? 'Moje poloha' : 'Vybraný bod',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}'
                  '${me && _meAccuracy != null ? ' · přesnost ±${_meAccuracy!.round()} m' : ''}'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _savePoint(p, me ? 'Moje poloha' : '');
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Uložit jako místo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fit() {
    if (!_ready) return;
    if (_points.isEmpty) {
      _map.move(const LatLng(20, 100), 2);
    } else if (_points.length == 1) {
      _map.move(_points.first, 13);
    } else {
      _map.fitCamera(CameraFit.coordinates(
        coordinates: _points,
        padding: const EdgeInsets.all(48),
        maxZoom: 15,
      ));
    }
  }

  void _showPlace(Place p, Trip? trip) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(placeIcon(p.type), color: placeColor(p.type)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(p.name,
                      style: Theme.of(ctx).textTheme.titleLarge),
                ),
              ]),
              const SizedBox(height: 8),
              Text([
                placeTypes[p.type] ?? p.type,
                if (p.country != null && p.country!.isNotEmpty) p.country!,
                if (trip != null) trip.name,
              ].join(' · ')),
              if (p.note != null && p.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(p.note!),
              ],
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                FilledButton.icon(
                  onPressed: () => openPlaceInMaps(p),
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigovat'),
                ),
                if (trip != null)
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/trips/trip/${trip.id}/places');
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Místa cesty'),
                  ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  /// Seznam míst bez polohy – klepnutím se otevře hledání podle názvu.
  void _showUnknown(List<Place> list, Map<String, Trip> tripById) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          // živý seznam: po doplnění polohy místo zmizí
          final all = ref.watch(allPlacesProvider).value ?? const <Place>[];
          final ids = {for (final p in list) p.id};
          final left = all.where((p) => ids.contains(p.id) && !hasCoords(p)).toList();
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            builder: (ctx, scroll) => ListView(
              controller: scroll,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text('Místa bez polohy – klepni a najdi je podle názvu'),
                ),
                if (left.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Hotovo, všechna místa mají polohu.',
                        textAlign: TextAlign.center),
                  ),
                for (final p in left)
                  ListTile(
                    leading: Icon(placeIcon(p.type), color: placeColor(p.type)),
                    title: Text(p.name),
                    subtitle: Text(tripById[p.tripId]?.name ?? ''),
                    trailing: const Icon(Icons.search),
                    onTap: () => locatePlace(ctx, ref, p),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider).value ?? const <Trip>[];
    final all = ref.watch(allPlacesProvider).value ?? const <Place>[];
    final tripById = {for (final t in trips) t.id: t};
    if (_tripId != null && !tripById.containsKey(_tripId)) _tripId = null;

    final places = [
      for (final p in all)
        if (tripById.containsKey(p.tripId) &&
            (_tripId == null || p.tripId == _tripId))
          p,
    ];
    final located = places.where(hasCoords).toList();
    final unknown = places.length - located.length;

    final points = [for (final p in located) LatLng(p.lat, p.lng)];
    final changed = points.length != _points.length ||
        Iterable.generate(points.length).any((i) => points[i] != _points[i]);
    if (changed) {
      _points = points;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            tooltip: 'Vložit odkaz z Google Map',
            icon: const Icon(Icons.content_paste_go),
            onPressed: _pasteLink,
          ),
        ],
      ),
      body: Column(
        children: [
          if (trips.length > 1)
            SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: const Icon(Icons.public, size: 18),
                      label: const Text('Vše'),
                      selected: _tripId == null,
                      onSelected: (_) => setState(() => _tripId = null),
                    ),
                  ),
                  for (final t in trips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(t.name),
                        selected: _tripId == t.id,
                        onSelected: (_) => setState(() => _tripId = t.id),
                      ),
                    ),
                ],
              ),
            ),
          if (unknown > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(switch (unknown) {
                    1 => '1 místo nemá polohu',
                    < 5 => '$unknown místa nemají polohu',
                    _ => '$unknown míst nemá polohu',
                  }),
                ),
                TextButton(
                  onPressed: () => _showUnknown(
                      places.where((p) => !hasCoords(p)).toList(), tripById),
                  child: const Text('Doplnit'),
                ),
              ]),
            ),
          Expanded(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: const LatLng(20, 100),
                initialZoom: 2,
                minZoom: 2,
                maxZoom: 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onLongPress: (_, p) => _pointSheet(p, me: false),
                onMapReady: () {
                  _ready = true;
                  _fit();
                },
              ),
              children: [
                const MapTiles(),
                if (_me != null && (_meAccuracy ?? 0) > 20)
                  CircleLayer(circles: [
                    CircleMarker(
                      point: _me!,
                      radius: _meAccuracy!,
                      useRadiusInMeter: true,
                      color: const Color(0x334AA3F0),
                      borderColor: const Color(0x884AA3F0),
                      borderStrokeWidth: 1,
                    ),
                  ]),
                MarkerLayer(
                  markers: [
                    if (_me != null)
                      Marker(
                        point: _me!,
                        width: 24,
                        height: 24,
                        child: GestureDetector(
                          onTap: () => _pointSheet(_me!, me: true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F80ED),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(blurRadius: 4, color: Colors.black45)
                              ],
                            ),
                          ),
                        ),
                      ),
                    for (final p in located)
                      Marker(
                        point: LatLng(p.lat, p.lng),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _showPlace(p, tripById[p.tripId]),
                          child: _Pin(type: p.type),
                        ),
                      ),
                  ],
                ),
                const MapAttribution(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (located.isNotEmpty) ...[
            FloatingActionButton.small(
              heroTag: 'fit',
              tooltip: 'Zobrazit všechna místa',
              onPressed: _fit,
              child: const Icon(Icons.fit_screen),
            ),
            const SizedBox(height: 12),
          ],
          FloatingActionButton(
            heroTag: 'me',
            tooltip: 'Moje poloha',
            onPressed: _showMe,
            child: Icon(_me == null ? Icons.my_location_outlined : Icons.my_location),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: placeColor(type),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black45)],
      ),
      child: Icon(placeIcon(type), color: Colors.white, size: 20),
    );
  }
}
