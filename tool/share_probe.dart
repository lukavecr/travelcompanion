// ignore_for_file: avoid_print
// Ruční kontrola sdílení: dart run tool/share_probe.dart "<sdílený text>"
import 'package:travelcompanion/core/place_locator.dart';
import 'package:travelcompanion/features/share_intake/share_parser.dart';

Future<void> main(List<String> args) async {
  for (final a in args) {
    final s = parseSharedText(a);
    var name = s.name.isEmpty ? null : s.name;
    String? address;
    var c = s.coords;
    if (s.url != null) {
      final r = await resolveMaps(s.url!);
      name ??= r.name;
      address = r.address;
      c ??= r.coords;
    }
    print('name=$name | address=$address | coords=${c?.lat},${c?.lng}');
    if (c == null) {
      final g = await locateByText(name: name, address: address);
      print('  -> ${g?.lat},${g?.lng} ${g?.country} (${g?.address})');
    }
  }
}
