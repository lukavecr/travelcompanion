import 'package:http/http.dart' as http;

class Coords {
  const Coords(this.lat, this.lng);
  final double lat;
  final double lng;
}

class SharedPlace {
  const SharedPlace({required this.name, this.url, this.coords});
  final String name; // může být prázdný
  final String? url;
  final Coords? coords;
}

class ResolvedMaps {
  const ResolvedMaps({this.coords, this.name, this.origin, this.destination});
  final Coords? coords;
  final String? name;
  final String? origin; // u sdílené trasy (.../maps/dir/Odkud/Kam)
  final String? destination;
}

String _dec(String s) {
  var t = s.replaceAll('+', ' ');
  try {
    t = Uri.decodeComponent(t);
  } catch (_) {}
  return t.trim();
}

/// Z adresy trasy .../maps/dir/Odkud/Kam/... vrátí [odkud, kam].
List<String>? routeFromUri(Uri uri) {
  final seg = uri.pathSegments;
  final i = seg.indexOf('dir');
  if (i < 0 || seg.length < i + 3) return null;
  final o = _dec(seg[i + 1]);
  final d = _dec(seg[i + 2]);
  bool bad(String x) => x.isEmpty || x.startsWith('@') || x.startsWith('data=');
  if (bad(o) || bad(d)) return null;
  return [o, d];
}

final _patterns = <RegExp>[
  RegExp(r'@(-?\d{1,3}\.\d+),(-?\d{1,3}\.\d+)'),
  RegExp(r'!3d(-?\d{1,3}\.\d+)!4d(-?\d{1,3}\.\d+)'),
  RegExp(
      r'[?&](?:q|ll|query|destination|center)=(-?\d{1,3}\.\d+),\s*(-?\d{1,3}\.\d+)'),
  RegExp(r'^\s*(-?\d{1,3}\.\d+),\s*(-?\d{1,3}\.\d+)\s*$'),
];

final _coordsOnly = RegExp(r'^\s*-?\d{1,3}\.\d+,\s*-?\d{1,3}\.\d+\s*$');

Coords? coordsFrom(String input) {
  var s = input;
  try {
    s = Uri.decodeComponent(input);
  } catch (_) {}
  for (final re in _patterns) {
    final m = re.firstMatch(s);
    if (m != null) {
      final lat = double.tryParse(m.group(1)!);
      final lng = double.tryParse(m.group(2)!);
      if (lat != null && lng != null && lat.abs() <= 90 && lng.abs() <= 180) {
        return Coords(lat, lng);
      }
    }
  }
  return null;
}

/// Název místa z adresy typu .../maps/place/Grand+Palace/@13.7,100.4,17z...
String? nameFromUri(Uri uri) {
  String? raw;
  final seg = uri.pathSegments;
  final i = seg.indexOf('place');
  if (i >= 0 && i + 1 < seg.length) raw = seg[i + 1];
  raw ??= uri.queryParameters['q'];
  if (raw == null) return null;
  var s = raw.replaceAll('+', ' ');
  try {
    s = Uri.decodeComponent(s);
  } catch (_) {}
  s = s.split(',').first.trim();
  if (s.isEmpty || s.startsWith('@') || _coordsOnly.hasMatch(s)) return null;
  return s;
}

/// Z textu sdíleného z Google Maps vytáhne název, odkaz a (když jde) souřadnice.
SharedPlace parseSharedText(String text) {
  final urlMatch = RegExp(r'https?://\S+').firstMatch(text);
  final url = urlMatch?.group(0);
  final lines = text
      .split(RegExp(r'[\r\n]+'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.contains('http'))
      .toList();
  return SharedPlace(
    name: lines.isNotEmpty ? lines.first : '',
    url: url,
    coords: coordsFrom(text),
  );
}

/// Rozbalí zkrácený odkaz (maps.app.goo.gl) a hledá název a souřadnice
/// v adresách, přes které se přesměrovává.
Future<ResolvedMaps> resolveMaps(String url) async {
  final client = http.Client();
  Coords? coords;
  String? name;
  List<String>? route;
  try {
    var current = Uri.parse(url);
    for (var i = 0; i < 8; i++) {
      coords ??= coordsFrom(current.toString());
      name ??= nameFromUri(current);
      route ??= routeFromUri(current);
      if (route != null) break;
      if (coords != null && name != null) break;

      final cont = current.queryParameters['continue'];
      if (current.host.contains('consent.google') && cont != null) {
        current = Uri.parse(cont);
        continue;
      }

      final req = http.Request('GET', current)
        ..followRedirects = false
        ..headers['user-agent'] =
            'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36';
      final res = await client.send(req).timeout(const Duration(seconds: 10));
      if (res.statusCode >= 300 && res.statusCode < 400) {
        final loc = res.headers['location'];
        if (loc == null) break;
        current = current.resolve(loc);
        continue;
      }
      break;
    }
  } catch (_) {
    // bez internetu nebo odkaz nejde rozbalit
  } finally {
    client.close();
  }
  return ResolvedMaps(
    coords: route != null ? null : coords,
    name: route != null ? null : name,
    origin: route?[0],
    destination: route?[1],
  );
}
