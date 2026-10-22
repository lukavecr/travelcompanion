import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/map_tiles.dart';
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
      appBar: AppBar(title: const Text('Mapa')),
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
                onMapReady: () {
                  _ready = true;
                  _fit();
                },
              ),
              children: [
                const MapTiles(),
                MarkerLayer(
                  markers: [
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
      floatingActionButton: located.isEmpty
          ? null
          : FloatingActionButton.small(
              tooltip: 'Zobrazit všechna místa',
              onPressed: _fit,
              child: const Icon(Icons.fit_screen),
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
