import 'geocode.dart';
import 'plus_code.dart';

/// Dohledá polohu místa z textu (Plus Code → adresa → název). Bez výsledku / bez sítě = null.
/// Používá se, když sdílený odkaz z Google Map neobsahuje souřadnice.
Future<GeoResult?> locateByText({String? name, String? address}) async {
  final texts = [
    for (final t in [address, name])
      if (t != null && t.trim().isNotEmpty) t.trim(),
  ];
  try {
    // 1) Plus Code (např. „JP9V+JX2 Huong Pagoda“) – přesná poloha
    for (final t in texts) {
      final pc = findPlusCode(t);
      if (pc == null) continue;
      if (!isShortPlusCode(pc.code)) {
        final (lat, lng) = decodePlusCode(pc.code);
        return GeoResult(
          name: pc.rest.isEmpty ? pc.code : pc.rest.split(',').first,
          address: t,
          lat: lat,
          lng: lng,
          country: await reverseCountry(lat, lng),
        );
      }
      if (pc.rest.isEmpty) continue;
      // zkrácený kód potřebuje přibližné místo (město, název) jako vodítko
      final ref = await _first([pc.rest, ..._shorter(pc.rest)]);
      if (ref == null) continue;
      final (lat, lng) = recoverPlusCode(pc.code, ref.lat, ref.lng);
      return GeoResult(
        name: pc.rest.split(',').first,
        address: t,
        lat: lat,
        lng: lng,
        country: ref.country,
      );
    }

    // 2) adresa / název přes Nominatim (i bez čísla na začátku: „41 Phlio Waterfall…“)
    return await _first([
      for (final t in texts) ...[t, ..._shorter(t)],
      for (final t in texts)
        if (RegExp(r'^\d+\s+\D').hasMatch(t)) t.replaceFirst(RegExp(r'^\d+\s+'), ''),
    ]) ??
        // 3) aspoň obec / okres z adresy (bez názvu místa) – přibližně
        await _first(_localities(address ?? name));
  } catch (_) {
    return null;
  }
}

/// Kratší varianty adresy: „název, město, země“ a „název, země“.
List<String> _shorter(String text) {
  final parts = text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  if (parts.length < 3) return const [];
  return [
    '${parts.first}, ${parts[parts.length - 2]}, ${parts.last}',
    '${parts.first}, ${parts.last}',
  ];
}

/// „Místo, obec, okres, země“ → [„obec, okres, země“, „okres, země“].
List<String> _localities(String? address) {
  if (address == null) return const [];
  final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  return [
    for (var i = 1; i < parts.length - 1; i++) parts.sublist(i).join(', '),
  ];
}

Future<GeoResult?> _first(List<String> queries) async {
  final seen = <String>{};
  for (final q in queries) {
    if (!seen.add(q.toLowerCase())) continue;
    final r = await searchPlaces(q);
    if (r.isNotEmpty) return r.first;
  }
  return null;
}
