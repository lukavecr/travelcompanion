import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import 'app_settings.dart';


const _ofm = 'https://tiles.openfreemap.org';

/// Popisky: zvolený jazyk → latinka → místní název.
/// [lang] null = místní názvy (jak je píše daná země).
List<Object> _labelExpr(String? lang) => lang == null
    ? ['coalesce', ['get', 'name'], ['get', 'name:latin']]
    : [
      'coalesce',
      ['get', 'name:$lang'],
      if (lang == 'en') ['get', 'name_en'],
      ['get', 'name:latin'],
      ['get', 'name'],
    ];

/// Načte styl OpenFreeMap (zdarma, bez klíče) a přepne popisky do [lang].
Future<Style> loadMapStyle({required bool dark, required String? lang}) async {
  Future<dynamic> getJson(String url) async {
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Mapa: $url → ${res.statusCode}');
    return jsonDecode(res.body);
  }

  final style = Map<String, dynamic>.from(
      await getJson('$_ofm/styles/${dark ? 'dark' : 'liberty'}') as Map);
  final sources = Map<String, dynamic>.from(style['sources'] as Map);

  // jen vektorové zdroje (stínovaný reliéf Natural Earth vynecháme)
  final providers = <String, VectorTileProvider>{};
  for (final e in sources.entries.toList()) {
    final src = e.value as Map;
    if (src['type'] != 'vector') {
      sources.remove(e.key);
      continue;
    }
    final tileJson = src['url'] is String ? await getJson(src['url'] as String) as Map : src;
    providers[e.key] = NetworkVectorTileProvider(
      urlTemplate: (tileJson['tiles'] as List).first as String,
      maximumZoom: tileJson['maxzoom'] as int? ?? 14,
      minimumZoom: tileJson['minzoom'] as int? ?? 0,
    );
  }
  style['sources'] = sources;

  final label = _labelExpr(lang);
  style['layers'] = [
    for (final l in (style['layers'] as List).cast<Map<String, dynamic>>())
      if (l['source'] == null || sources.containsKey(l['source']))
        if (l['layout'] is Map &&
            jsonEncode((l['layout'] as Map)['text-field'] ?? '').contains('name'))
          {
            ...l,
            'layout': {...(l['layout'] as Map), 'text-field': label},
          }
        else
          l,
  ];

  SpriteStyle? sprites;
  final sprite = style['sprite'];
  if (sprite is String) {
    try {
      final index = await getJson('$sprite@2x.json');
      sprites = SpriteStyle(
        atlasProvider: () async =>
            (await http.get(Uri.parse('$sprite@2x.png'))).bodyBytes,
        index: vtr.SpriteIndexReader().read(index),
      );
    } catch (_) {}
  }

  return Style(
    theme: vtr.ThemeReader().read(style),
    providers: TileProviders(providers),
    sprites: sprites,
  );
}

/// Styl se načte jednou za běh aplikace pro každou kombinaci (tmavý, jazyk popisků).
final mapStyleProvider = FutureProvider.family<Style, (bool, String?)>(
    (ref, k) => loadMapStyle(dark: k.$1, lang: k.$2));

/// Podklad mapy: vektorové dlaždice OpenFreeMap s anglickými popisky.
/// Když se styl nepodaří načíst, použije se obyčejná mapa OSM.
class MapTiles extends ConsumerWidget {
  const MapTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final style = ref.watch(mapStyleProvider((dark, AppSettings.instance.mapLabelLanguage)));
    return style.when(
      data: (s) => VectorTileLayer(
        key: ValueKey(dark),
        theme: s.theme,
        sprites: s.sprites,
        tileProviders: s.providers,
        layerMode: VectorTileLayerMode.vector,
        maximumZoom: 19,
        fileCacheTtl: const Duration(days: 60), // prohlédnutá místa i offline
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.lukrom.travelcompanion',
      ),
    );
  }
}

/// Povinné uvedení zdrojů mapy.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  @override
  Widget build(BuildContext context) => const SimpleAttributionWidget(
        source: Text('OpenFreeMap © OpenStreetMap'),
      );
}
