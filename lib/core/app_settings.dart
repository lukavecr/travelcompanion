import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/tr.dart';

/// Uživatelská nastavení aplikace (v telefonu, SharedPreferences). Načtou se v `main()`
/// před spuštěním, takže je mohou synchronně číst i formátovací funkce (`format.dart`).
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final instance = AppSettings._();

  // jazyky se ukazují vždy svým vlastním názvem, jen „Podle telefonu“ se překládá
  static Map<String, String> get languages => {
    'system': tr('Podle telefonu'),
    'cs': tr('Čeština'),
    'en': tr('English'),
    'de': tr('Deutsch'),
    'es': tr('Español'),
  };
  static const supportedLanguages = ['cs', 'en', 'de', 'es'];

  static const currencies = ['CZK', 'EUR', 'USD', 'GBP', 'CHF', 'PLN', 'HUF', 'AUD', 'CAD', 'NZD', 'JPY'];

  static const dateFormats = {
    'dmy_dot': '23. 10. 2026',
    'dmy_slash': '23/10/2026',
    'mdy': '10/23/2026',
    'iso': '2026-10-23',
  };

  static Map<String, String> get startTabs => {
    'trips': tr('Cesty'),
    'map': tr('Mapa'),
    'docs': tr('Doklady'),
    'money': tr('Peníze'),
    'vault': tr('Vault'),
  };

  static Map<int, String> get lockOptions => {
    0: tr('Hned'),
    60: tr('Po 1 minutě'),
    300: tr('Po 5 minutách'),
    -1: tr('Nezamykat'),
  };

  late SharedPreferences _p;

  String language = 'system';
  ThemeMode themeMode = ThemeMode.dark;
  String homeCurrency = 'CZK';
  int weekStart = 1; // 1 = pondělí, 0 = neděle, 6 = sobota
  bool use24h = true;
  String dateFormat = 'dmy_dot';
  String startTab = 'trips';
  bool mapLocalNames = false; // false = názvy v jazyce aplikace, true = místní
  int lockAfterSeconds = 60;
  bool expiryReminders = true;
  int expiryReminderMinutes = 9 * 60;
  bool onboardingDone = false;
  bool tripReminders = true; // check-in 24 h před letem, odlet, den odjezdu z ubytování

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    language = _p.getString('set_language') ?? language;
    themeMode = ThemeMode.values.byName(_p.getString('set_theme') ?? themeMode.name);
    homeCurrency = _p.getString('set_currency') ?? homeCurrency;
    weekStart = _p.getInt('set_week_start') ?? weekStart;
    use24h = _p.getBool('set_24h') ?? use24h;
    dateFormat = _p.getString('set_date_format') ?? dateFormat;
    startTab = _p.getString('set_start_tab') ?? startTab;
    mapLocalNames = _p.getBool('set_map_local') ?? mapLocalNames;
    lockAfterSeconds = _p.getInt('set_lock_after') ?? lockAfterSeconds;
    expiryReminders = _p.getBool('set_expiry_on') ?? expiryReminders;
    expiryReminderMinutes = _p.getInt('set_expiry_time') ?? expiryReminderMinutes;
    onboardingDone = _p.getBool('set_onboarding_done') ?? onboardingDone;
    tripReminders = _p.getBool('set_trip_reminders') ?? tripReminders;
  }

  /// Jazyk, který se opravdu použije (u „Podle telefonu“ podle jazyka systému).
  String get effectiveLanguage {
    if (language != 'system') return language;
    final sys = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return supportedLanguages.contains(sys) ? sys : 'en';
  }

  /// Jazyk názvů na mapě: jazyk aplikace, nebo null = místní názvy.
  String? get mapLabelLanguage => mapLocalNames ? null : effectiveLanguage;

  Future<void> _save(void Function() apply, Future<void> Function() persist) async {
    apply();
    await persist();
    notifyListeners();
  }

  Future<void> setLanguage(String v) =>
      _save(() => language = v, () => _p.setString('set_language', v));
  Future<void> setThemeMode(ThemeMode v) =>
      _save(() => themeMode = v, () => _p.setString('set_theme', v.name));
  Future<void> setHomeCurrency(String v) =>
      _save(() => homeCurrency = v, () => _p.setString('set_currency', v));
  Future<void> setWeekStart(int v) =>
      _save(() => weekStart = v, () => _p.setInt('set_week_start', v));
  Future<void> setUse24h(bool v) => _save(() => use24h = v, () => _p.setBool('set_24h', v));
  Future<void> setDateFormat(String v) =>
      _save(() => dateFormat = v, () => _p.setString('set_date_format', v));
  Future<void> setStartTab(String v) =>
      _save(() => startTab = v, () => _p.setString('set_start_tab', v));
  Future<void> setMapLocalNames(bool v) =>
      _save(() => mapLocalNames = v, () => _p.setBool('set_map_local', v));
  Future<void> setLockAfter(int v) =>
      _save(() => lockAfterSeconds = v, () => _p.setInt('set_lock_after', v));
  Future<void> setExpiryReminders(bool v) =>
      _save(() => expiryReminders = v, () => _p.setBool('set_expiry_on', v));
  Future<void> setOnboardingDone(bool v) =>
      _save(() => onboardingDone = v, () => _p.setBool('set_onboarding_done', v));
  Future<void> setTripReminders(bool v) =>
      _save(() => tripReminders = v, () => _p.setBool('set_trip_reminders', v));
  Future<void> setExpiryReminderMinutes(int v) =>
      _save(() => expiryReminderMinutes = v, () => _p.setInt('set_expiry_time', v));
}
