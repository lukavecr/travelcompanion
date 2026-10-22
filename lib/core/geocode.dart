import 'dart:convert';

import 'package:http/http.dart' as http;

import 'country_info.dart';

/// Země podle souřadnic (OpenStreetMap Nominatim, zdarma, bez klíče).
Future<String?> reverseCountry(double lat, double lng) async {
  try {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': '$lat',
      'lon': '$lng',
      'zoom': '3',
      'accept-language': 'cs',
    });
    final res = await http
        .get(uri, headers: {'User-Agent': 'TravelCompanionAI/1.0 (osobni aplikace)'})
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
