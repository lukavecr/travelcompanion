import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/geocode.dart';
import '../../core/map_tiles.dart';
import '../../data/database.dart';
import '../trips/trip_repository.dart';
import 'place_types.dart';

/// Najde polohu místa podle názvu a uloží ji (souřadnice + země).
Future<void> locatePlace(BuildContext context, WidgetRef ref, Place p) async {
  final r = await Navigator.of(context).push<GeoResult>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => LocatePlaceScreen(
      initialQuery: [
        p.name,
        if (p.country != null && p.country!.isNotEmpty) p.country!,
      ].join(', '),
    ),
  ));
  if (r == null) return;
  await ref
      .read(tripRepositoryProvider)
      .setPlaceLocation(p.id, lat: r.lat, lng: r.lng, country: r.country);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Poloha místa „${p.name}“ uložena')));
  }
}

class LocatePlaceScreen extends StatefulWidget {
  const LocatePlaceScreen({super.key, required this.initialQuery});
  final String initialQuery;

  @override
  State<LocatePlaceScreen> createState() => _LocatePlaceScreenState();
}

class _LocatePlaceScreenState extends State<LocatePlaceScreen> {
  late final _query = TextEditingController(text: widget.initialQuery);
  final _map = MapController();
  List<GeoResult> _results = const [];
  GeoResult? _picked;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() {
      _busy = true;
      _message = null;
      _picked = null;
    });
    try {
      final r = await searchPlaces(_query.text);
      if (!mounted) return;
      setState(() {
        _results = r;
        _message = r.isEmpty
            ? 'Nic nenalezeno. Zkus kratší název, anglický název nebo přidej město.'
            : null;
      });
      if (r.isNotEmpty) _pick(r.first);
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Hledání se nepovedlo – jsi připojený k internetu?');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _pick(GeoResult r) {
    setState(() => _picked = r);
    _map.move(LatLng(r.lat, r.lng), 14);
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    return Scaffold(
      appBar: AppBar(title: const Text('Najít polohu')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                labelText: 'Název místa, město, adresa',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _busy ? null : _search,
                ),
              ),
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          SizedBox(
            height: 220,
            child: FlutterMap(
              mapController: _map,
              options: const MapOptions(
                initialCenter: LatLng(20, 100),
                initialZoom: 2,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                const MapTiles(),
                if (picked != null)
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(picked.lat, picked.lng),
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on,
                          size: 40, color: Color(0xFFE5677A)),
                    ),
                  ]),
                const MapAttribution(),
              ],
            ),
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_message!, textAlign: TextAlign.center),
            ),
          Expanded(
            child: ListView(
              children: [
                for (final r in _results)
                  ListTile(
                    leading: Icon(placeIcon('custom')),
                    title: Text(r.name),
                    subtitle: Text(r.address,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    selected: identical(r, picked),
                    onTap: () => _pick(r),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: picked == null ? null : () => Navigator.pop(context, picked),
            icon: const Icon(Icons.check),
            label: Text(picked == null ? 'Vyber místo ze seznamu' : 'Použít „${picked.name}“'),
          ),
        ),
      ),
    );
  }
}
