import '../core/app_settings.dart';
import 'de.dart';
import 'en.dart';
import 'es.dart';

/// Překlad textu aplikace. Klíčem je český text (čeština je výchozí jazyk vývoje),
/// překlady jsou v `en.dart`, `de.dart`, `es.dart`. Chybějící překlad = česky.
///
/// Proměnné se píšou do složených závorek: `tr('Za {n} dní', {'n': 5})`.
/// Kontrola, že nic nechybí: `flutter test test/l10n_test.dart`.
String tr(String cs, [Map<String, Object?> args = const {}]) {
  final lang = AppSettings.instance.effectiveLanguage;
  var s = (switch (lang) {
        'en' => en[cs],
        'de' => de[cs],
        'es' => es[cs],
        _ => null,
      }) ??
      cs;
  if (args.isNotEmpty) {
    args.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
  }
  return s;
}

/// Všechny jazykové tabulky (pro test úplnosti).
const translations = {'en': en, 'de': de, 'es': es};
