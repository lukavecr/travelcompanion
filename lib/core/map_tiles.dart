import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

import '../features/offline_maps/offline_tiles.dart';
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
/// Stáhne soubor stylu/ikon a uloží kopii do telefonu; bez internetu vrátí uloženou kopii
/// (mapa pak funguje i offline – s dlaždicemi ze stažených oblastí nebo z cache).
Future<Uint8List> _cachedGet(String url) async {
  final name = url.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
  final file = File('${(await offlineDir()).path}/style_$name');
  try {
    final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('Mapa: $url → ${res.statusCode}');
    await file.writeAsBytes(res.bodyBytes);
    return res.bodyBytes;
  } catch (e) {
    if (await file.exists()) return file.readAsBytes();
    rethrow;
  }
}

Future<Style> loadMapStyle({required bool dark, required String? lang}) async {
  Future<dynamic> getJson(String url) async => jsonDecode(utf8.decode(await _cachedGet(url)));
  await OfflineMaps.instance.load();

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
    final template = (tileJson['tiles'] as List).first as String;
    if (e.key == 'openmaptiles') OfflineMaps.instance.urlTemplate = template;
    providers[e.key] = OfflineFirstTileProvider(NetworkVectorTileProvider(
      urlTemplate: template,
      maximumZoom: tileJson['maxzoom'] as int? ?? 14,
      minimumZoom: tileJson['minzoom'] as int? ?? 0,
    ));
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
        atlasProvider: () => _cachedGet('$sprite@2x.png'),
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
