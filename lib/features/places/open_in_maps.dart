import 'package:url_launcher/url_launcher.dart';

import '../../data/database.dart';

/// Otevře místo v mapové aplikaci (Google Maps, prohlížeč...).
Future<void> openPlaceInMaps(Place p) async {
  final hasCoords = !(p.lat == 0 && p.lng == 0); // 0,0 = souřadnice neznámé
  final url = p.mapUrl ??
      (hasCoords
          ? 'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lng}'
          : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(p.name)}');
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
