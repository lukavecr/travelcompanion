import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/geocode.dart';
import '../../core/place_locator.dart';
import '../../core/map_tiles.dart';
import '../../data/database.dart';
import '../share_intake/share_parser.dart';
import '../trips/trip_repository.dart';
import 'place_types.dart';
import '../../l10n/tr.dart';

/// Najde polohu místa podle názvu a uloží ji (souřadnice + země).
Future<void> locatePlace(BuildContext context, WidgetRef ref, Place p) async {
  final r = await Navigator.of(context).push<GeoResult>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => LocatePlaceScreen(
      initialQuery: [
        p.name,
        if (p.country != null && p.country!.isNotEmpty) p.country!,
      ].join(', '),
      name: p.name,
      mapUrl: p.mapUrl,
    ),
  ));
  if (r == null) return;
  await ref
      .read(tripRepositoryProvider)
      .setPlaceLocation(p.id, lat: r.lat, lng: r.lng, country: r.country);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('Poloha místa „{name}“ uložena', {'name': p.name}))));
  }
}

class LocatePlaceScreen extends StatefulWidget {
  const LocatePlaceScreen(
      {super.key, required this.initialQuery, this.name, this.mapUrl});
  final String initialQuery;
  final String? name; // u uloženého místa: zkusí se odkaz z Map a Plus Code
  final String? mapUrl;

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
    if (widget.name != null || widget.mapUrl != null) {
      _prefill();
    } else {
      _search();
    }
  }

  /// Nejdřív odkaz z Google Map (souřadnice / adresa), pak Plus Code a název.
  Future<void> _prefill() async {
    setState(() => _busy = true);
    GeoResult? found;
    try {
      String? address;
      if (widget.mapUrl != null) {
        final r = await resolveMaps(widget.mapUrl!);
        address = r.address;
        if (r.coords != null) {
          found = GeoResult(
            name: r.name ?? widget.name ?? '',
            address: r.address ?? tr('Poloha z odkazu Google Map'),
            lat: r.coords!.lat,
            lng: r.coords!.lng,
            country: await reverseCountry(r.coords!.lat, r.coords!.lng),
          );
        }
      }
      found ??= await locateByText(name: widget.name, address: address);
      if (address != null && mounted) _query.text = address;
    } catch (_) {}
    if (!mounted) return;
    if (found == null) return _search();
    final f = found;
    setState(() {
      _busy = false;
      _results = [f];
    });
    _pick(f);
  }

  Future<void> _search() async {
    setState(() {
      _busy = true;
      _message = null;
      _picked = null;
    });
    try {
      var r = await searchPlaces(_query.text);
      var approx = false;
      if (r.isEmpty) {
        // zkus kratší varianty a nakonec aspoň obec / okres
        final g = await locateByText(address: _query.text);
        if (g != null) {
          r = [g];
          approx = true;
        }
      }
      if (!mounted) return;
      setState(() {
        _results = r;
        _message = r.isEmpty
            ? tr('Nic nenalezeno. Zkus kratší nebo anglický název, nebo najdi místo na mapě a klepni na něj.')
            : approx
                ? tr('Přesně to nenašlo – ukazuji nejbližší shodu. Případně klepni do mapy na přesné místo.')
                : null;
      });
      if (r.isNotEmpty) _pick(r.first);
    } catch (_) {
      if (mounted) {
        setState(() => _message = tr('Hledání se nepovedlo – jsi připojený k internetu?'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _pick(GeoResult r) {
    setState(() => _picked = r);
    try {
      _map.move(LatLng(r.lat, r.lng), 14);
    } catch (_) {
      // mapa ještě není vykreslená
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _map.move(LatLng(r.lat, r.lng), 14));
    }
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;
    return Scaffold(
      appBar: AppBar(title: Text(tr('Najít polohu'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _query,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                labelText: tr('Název místa, město, adresa'),
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
            height: 280,
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: const LatLng(20, 100),
                initialZoom: 2,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                // ruční volba: klepnutí do mapy na přesné místo
                onTap: (_, p) => setState(() => _picked = GeoResult(
                      name: widget.name ?? tr('Vybraný bod'),
                      address: tr('Bod vybraný na mapě'),
                      lat: p.latitude,
                      lng: p.longitude,
                    )),
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
          Padding(
            padding: EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Text(tr('Tip: můžeš i klepnout do mapy na přesné místo.'),
                style: TextStyle(fontSize: 13)),
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
            label: Text(picked == null ? tr('Vyber místo ze seznamu') : tr('Použít „{name}“', {'name': picked.name})),
          ),
        ),
      ),
    );
  }
}
