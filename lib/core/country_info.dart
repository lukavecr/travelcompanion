/// Země (česky) -> měna. Slouží k tipování země a měny z dokladů a účtenek.
const _countryCurrency = <String, String>{
  'Česko': 'CZK',
  'Japonsko': 'JPY',
  'Thajsko': 'THB',
  'Vietnam': 'VND',
  'Kambodža': 'KHR',
  'Laos': 'LAK',
  'Malajsie': 'MYR',
  'Singapur': 'SGD',
  'Indonésie': 'IDR',
  'Filipíny': 'PHP',
  'Čína': 'CNY',
  'Hongkong': 'HKD',
  'Tchaj-wan': 'TWD',
  'Jižní Korea': 'KRW',
  'Indie': 'INR',
  'Nový Zéland': 'NZD',
  'Austrálie': 'AUD',
  'USA': 'USD',
  'Havaj': 'USD',
  'Mexiko': 'MXN',
  'Kanada': 'CAD',
  'Velká Británie': 'GBP',
  'Německo': 'EUR',
  'Francie': 'EUR',
  'Itálie': 'EUR',
  'Španělsko': 'EUR',
  'Rakousko': 'EUR',
};

/// Nominatim a jiné zdroje vrací jiné názvy než používáš ty.
const _aliases = <String, String>{
  'Spojené státy americké': 'USA',
  'Spojené státy': 'USA',
  'Spojené království': 'Velká Británie',
  'Hong Kong': 'Hongkong',
  'Tchaj-wan': 'Tchaj-wan',
  'Korejská republika': 'Jižní Korea',
  'Čínská lidová republika': 'Čína',
};

/// Slova v textu dokladu, podle kterých se pozná země.
const _keywords = <String, String>{
  'japan': 'Japonsko',
  'tokyo': 'Japonsko',
  'osaka': 'Japonsko',
  'kyoto': 'Japonsko',
  'nara': 'Japonsko',
  'thailand': 'Thajsko',
  'bangkok': 'Thajsko',
  'phuket': 'Thajsko',
  'chiang mai': 'Thajsko',
  'vietnam': 'Vietnam',
  'viet nam': 'Vietnam',
  'hanoi': 'Vietnam',
  'ho chi minh': 'Vietnam',
  'cambodia': 'Kambodža',
  'laos': 'Laos',
  'malaysia': 'Malajsie',
  'singapore': 'Singapur',
  'indonesia': 'Indonésie',
  'bali': 'Indonésie',
  'philippines': 'Filipíny',
  'korea': 'Jižní Korea',
  'seoul': 'Jižní Korea',
  'china': 'Čína',
  'hong kong': 'Hongkong',
  'taiwan': 'Tchaj-wan',
  'new zealand': 'Nový Zéland',
  'australia': 'Austrálie',
  'mexico': 'Mexiko',
  'hawaii': 'Havaj',
  'honolulu': 'Havaj',
  'united states': 'USA',
};

String normalizeCountry(String name) => _aliases[name] ?? name;

/// Anglické názvy zemí → česky (plán z AI je anglicky, aplikace v češtině má české názvy).
const _englishNames = <String, String>{
  'czechia': 'Česko', 'czech republic': 'Česko', 'japan': 'Japonsko', 'thailand': 'Thajsko',
  'vietnam': 'Vietnam', 'viet nam': 'Vietnam', 'cambodia': 'Kambodža', 'laos': 'Laos',
  'malaysia': 'Malajsie', 'singapore': 'Singapur', 'indonesia': 'Indonésie', 'philippines': 'Filipíny',
  'china': 'Čína', 'hong kong': 'Hongkong', 'taiwan': 'Tchaj-wan', 'south korea': 'Jižní Korea',
  'korea': 'Jižní Korea', 'india': 'Indie', 'sri lanka': 'Srí Lanka', 'nepal': 'Nepál',
  'new zealand': 'Nový Zéland', 'australia': 'Austrálie', 'united states': 'USA', 'usa': 'USA',
  'mexico': 'Mexiko', 'canada': 'Kanada', 'united kingdom': 'Velká Británie', 'uk': 'Velká Británie',
  'germany': 'Německo', 'france': 'Francie', 'italy': 'Itálie', 'spain': 'Španělsko',
  'portugal': 'Portugalsko', 'austria': 'Rakousko', 'greece': 'Řecko', 'croatia': 'Chorvatsko',
  'turkey': 'Turecko', 'türkiye': 'Turecko', 'egypt': 'Egypt', 'morocco': 'Maroko',
  'peru': 'Peru', 'brazil': 'Brazílie', 'argentina': 'Argentina', 'chile': 'Chile',
  'iceland': 'Island', 'norway': 'Norsko', 'switzerland': 'Švýcarsko', 'netherlands': 'Nizozemsko',
  'poland': 'Polsko', 'slovakia': 'Slovensko', 'hungary': 'Maďarsko', 'united arab emirates': 'SAE',
};

/// Název země v jazyce aplikace (u češtiny převede anglický název).
String localCountryName(String name, {required String lang}) {
  final n = normalizeCountry(name.trim());
  if (lang != 'cs') return n;
  return _englishNames[n.toLowerCase()] ?? n;
}

String? currencyForCountry(String country) {
  final lc = country.toLowerCase();
  for (final e in _countryCurrency.entries) {
    if (e.key.toLowerCase() == lc) return e.value;
  }
  return null;
}

String? countryForCurrency(String currency) {
  if (currency == 'EUR') return null; // víc zemí
  for (final e in _countryCurrency.entries) {
    if (e.value == currency) return e.key;
  }
  return null;
}

bool hasKana(String s) => RegExp(r'[\u3040-\u30ff]').hasMatch(s);
bool hasThai(String s) => RegExp(r'[\u0e00-\u0e7f]').hasMatch(s);

/// Odhad země z textu dokladu: písmo, názvy míst, měna.
String? guessCountry(String text, {String? currency}) {
  if (hasKana(text)) return 'Japonsko';
  if (hasThai(text)) return 'Thajsko';
  final lower = text.toLowerCase();
  for (final e in _keywords.entries) {
    if (RegExp('\\b${RegExp.escape(e.key)}\\b').hasMatch(lower)) return e.value;
  }
  if (currency != null) return countryForCurrency(currency);
  return null;
}

/// Vrátí zemi tak, jak ji máš napsanou u cesty (stejný pravopis).
String? matchCountry(String? country, List<String> known) {
  if (country == null) return null;
  final c = normalizeCountry(country);
  for (final k in known) {
    if (k.toLowerCase() == c.toLowerCase()) return k;
  }
  return c;
}
