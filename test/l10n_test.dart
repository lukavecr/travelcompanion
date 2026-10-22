import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/core/app_settings.dart';
import 'package:travelcompanion/l10n/tr.dart';

void main() {
  test('všechny jazyky mají stejné klíče a stejné proměnné', () {
    final ph = RegExp(r'\{(\w+)\}');
    final en = translations['en']!;
    for (final MapEntry(key: lang, value: map) in translations.entries) {
      expect(map.keys.toSet(), en.keys.toSet(), reason: 'klíče v $lang');
      for (final e in map.entries) {
        final a = ph.allMatches(e.key).map((m) => m[1]).toSet();
        final b = ph.allMatches(e.value).map((m) => m[1]).toSet();
        expect(b, a, reason: '$lang: ${e.key}');
      }
    }
  });

  test('tr() přeloží a dosadí proměnné', () {
    AppSettings.instance.language = 'en';
    expect(tr('Den {n} · {day}', {'n': 3, 'day': 'Mon'}), 'Day 3 · Mon');
    AppSettings.instance.language = 'de';
    expect(tr('Nová cesta'), 'Neue Reise');
    AppSettings.instance.language = 'cs';
    expect(tr('Nová cesta'), 'Nová cesta');
  });
}
