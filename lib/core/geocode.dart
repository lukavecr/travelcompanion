import 'dart:convert';

import 'package:http/http.dart' as http;

import 'country_info.dart';

// Nominatim chce v User-Agent kontakt na autora aplikace.
const _headers = {'User-Agent': 'TravelCompanion/1.0 (lrtechcz@gmail.com)'};

/// Nominatim dovoluje max. 1 dotaz za sekundu.
DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
Future<void> _throttle() async {
  final wait = _last.add(const Duration(milliseconds: 1100)).difference(DateTime.now());
  if (!wait.isNegative) await Future.delayed(wait);
  _last = DateTime.now();
}

class GeoResult {
  const GeoResult({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.country,
  });
  final String name;
  final String address; // celý popis z Nominatim
  final double lat;
  final double lng;
  final String? country; // česky, normalizovaně
}

/// Hledání míst podle názvu (OpenStreetMap Nominatim). Prázdný seznam = nic / chyba sítě.
Future<List<GeoResult>> searchPlaces(String query) async {
  final q = query.trim();
  if (q.isEmpty) return const [];
  await _throttle();
  final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
    'format': 'jsonv2',
    'q': q,
    'limit': '8',
    'addressdetails': '1',
    'accept-language': 'cs,en',
  });
  final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));
  if (res.statusCode != 200) throw Exception('Nominatim ${res.statusCode}');
  final list = jsonDecode(res.body) as List<dynamic>;
  return [
    for (final e in list.cast<Map<String, dynamic>>())
      GeoResult(
        name: (e['name'] as String?)?.isNotEmpty == true
            ? e['name'] as String
            : (e['display_name'] as String).split(',').first,
        address: e['display_name'] as String,
        lat: double.parse(e['lat'] as String),
        lng: double.parse(e['lon'] as String),
        country: switch ((e['address'] as Map<String, dynamic>?)?['country']) {
          final String c => normalizeCountry(c),
          _ => null,
        },
      ),
  ];
}

/// Země podle souřadnic (OpenStreetMap Nominatim, zdarma, bez klíče).
Future<String?> reverseCountry(double lat, double lng) async {
  try {
    await _throttle();
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': '$lat',
      'lon': '$lng',
      'zoom': '3',
      'accept-language': 'cs',
    });
    final res = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final address = json['address'] as Map<String, dynamic>?;
    final c = address?['country'] as String?;
    return c == null ? null : normalizeCountry(c);
  } catch (_) {
    return null;
  }
}
