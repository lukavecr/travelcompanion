// Open Location Code („Plus Code“ z Google Map, např. „JP9V+JX2“ nebo „7P5MJP9V+JX2“).
// Výpočet běží v telefonu, bez internetu. Algoritmus: github.com/google/open-location-code
import 'dart:math' as math;

const _alphabet = '23456789CFGHJMPQRVWX';
const _pairRes = [20.0, 1.0, 0.05, 0.0025, 0.000125];

/// Plus Code v textu. Toleruje mezeru místo „+“ (tak to občas dorazí ze sdílení).
final plusCodeRe = RegExp(
    r'(?<![0-9A-Z])([23456789CFGHJMPQRVWX]{4,8})[+ ]([23456789CFGHJMPQRVWX]{2,7})(?![0-9A-Z])',
    caseSensitive: false);

/// Najde Plus Code v textu; vrací kód s „+“ a zbytek textu (obvykle místo/město).
({String code, String rest})? findPlusCode(String text) {
  final m = plusCodeRe.firstMatch(text);
  if (m == null) return null;
  final head = m.group(1)!.toUpperCase();
  // plný kód má před „+“ 8 znaků, zkrácený 4 nebo 6
  if (head.length.isOdd) return null;
  final rest = text.replaceRange(m.start, m.end, '').replaceAll(RegExp(r'^[\s,]+|[\s,]+$'), '');
  return (code: '$head+${m.group(2)!.toUpperCase()}', rest: rest);
}

bool isShortPlusCode(String code) => code.indexOf('+') < 8;

/// Střed plného kódu → (lat, lng).
(double, double) decodePlusCode(String code) {
  final c = code.replaceAll('+', '').toUpperCase().replaceAll(RegExp('0+\$'), '');
  var lat = -90.0, lng = -180.0;
  var latRes = 0.0, lngRes = 0.0;
  for (var i = 0; i < c.length && i < 10; i += 2) {
    final res = _pairRes[i ~/ 2];
    lat += _alphabet.indexOf(c[i]) * res;
    if (i + 1 < c.length) lng += _alphabet.indexOf(c[i + 1]) * res;
    latRes = lngRes = res;
  }
  for (var i = 10; i < c.length; i++) {
    final d = _alphabet.indexOf(c[i]);
    latRes /= 5;
    lngRes /= 4;
    lat += (d ~/ 4) * latRes;
    lng += (d % 4) * lngRes;
  }
  return (lat + latRes / 2, lng + lngRes / 2);
}

String _encodePrefix(double lat, double lng, int length) {
  var la = lat.clamp(-90.0, 89.9999999) + 90;
  var ln = ((lng + 180) % 360);
  final sb = StringBuffer();
  for (var i = 0; sb.length < length; i++) {
    final res = _pairRes[i];
    final dla = (la / res).floor();
    final dln = (ln / res).floor();
    la -= dla * res;
    ln -= dln * res;
    sb
      ..write(_alphabet[dla])
      ..write(_alphabet[dln]);
  }
  return sb.toString().substring(0, length);
}

/// Zkrácený kód doplní podle referenčního bodu (např. města z adresy).
(double, double) recoverPlusCode(String shortCode, double refLat, double refLng) {
  final code = shortCode.toUpperCase();
  final padding = 8 - code.indexOf('+');
  final resolution = math.pow(20, 2 - padding / 2).toDouble();
  final half = resolution / 2;
  var (lat, lng) = decodePlusCode(_encodePrefix(refLat, refLng, padding) + code);
  if (refLat + half < lat && lat - resolution >= -90) {
    lat -= resolution;
  } else if (refLat - half > lat && lat + resolution <= 90) {
    lat += resolution;
  }
  if (refLng + half < lng) {
    lng -= resolution;
  } else if (refLng - half > lng) {
    lng += resolution;
  }
  return (lat, lng);
}
