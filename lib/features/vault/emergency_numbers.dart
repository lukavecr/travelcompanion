import '../../l10n/tr.dart';

/// Druh tísňové linky (popisek se překládá při zobrazení).
enum EmergencyKind { general, police, ambulance, fire, tourist }

String emergencyLabel(EmergencyKind k) => switch (k) {
      EmergencyKind.general => tr('Tísňová linka'),
      EmergencyKind.police => tr('Policie'),
      EmergencyKind.ambulance => tr('Záchranka'),
      EmergencyKind.fire => tr('Hasiči'),
      EmergencyKind.tourist => tr('Turistická policie'),
    };

typedef EmergencyNumber = (EmergencyKind, String);

const _eu112 = [(EmergencyKind.general, '112')];

/// Tísňová čísla podle země (české názvy jako v `country_info.dart`).
/// Zdroj: oficiální čísla jednotlivých zemí; 112 funguje z mobilu v EU a v mnoha dalších zemích.
const emergencyNumbers = <String, List<EmergencyNumber>>{
  'Česko': [
    (EmergencyKind.general, '112'),
    (EmergencyKind.ambulance, '155'),
    (EmergencyKind.police, '158'),
    (EmergencyKind.fire, '150'),
  ],
  'Německo': _eu112,
  'Francie': _eu112,
  'Itálie': _eu112,
  'Španělsko': _eu112,
  'Rakousko': _eu112,
  'Velká Británie': [(EmergencyKind.general, '999'), (EmergencyKind.general, '112')],
  'USA': [(EmergencyKind.general, '911')],
  'Havaj': [(EmergencyKind.general, '911')],
  'Kanada': [(EmergencyKind.general, '911')],
  'Mexiko': [(EmergencyKind.general, '911')],
  'Japonsko': [(EmergencyKind.police, '110'), (EmergencyKind.ambulance, '119'), (EmergencyKind.fire, '119')],
  'Thajsko': [
    (EmergencyKind.police, '191'),
    (EmergencyKind.ambulance, '1669'),
    (EmergencyKind.fire, '199'),
    (EmergencyKind.tourist, '1155'),
  ],
  'Vietnam': [(EmergencyKind.police, '113'), (EmergencyKind.fire, '114'), (EmergencyKind.ambulance, '115')],
  'Kambodža': [(EmergencyKind.police, '117'), (EmergencyKind.ambulance, '119'), (EmergencyKind.fire, '118')],
  'Laos': [(EmergencyKind.police, '191'), (EmergencyKind.ambulance, '195'), (EmergencyKind.fire, '190')],
  'Malajsie': [(EmergencyKind.general, '999'), (EmergencyKind.general, '112')],
  'Singapur': [(EmergencyKind.police, '999'), (EmergencyKind.ambulance, '995'), (EmergencyKind.fire, '995')],
  'Indonésie': [
    (EmergencyKind.general, '112'),
    (EmergencyKind.police, '110'),
    (EmergencyKind.ambulance, '118'),
    (EmergencyKind.fire, '113'),
  ],
  'Filipíny': [(EmergencyKind.general, '911')],
  'Čína': [(EmergencyKind.police, '110'), (EmergencyKind.ambulance, '120'), (EmergencyKind.fire, '119')],
  'Hongkong': [(EmergencyKind.general, '999')],
  'Tchaj-wan': [(EmergencyKind.police, '110'), (EmergencyKind.ambulance, '119'), (EmergencyKind.fire, '119')],
  'Jižní Korea': [(EmergencyKind.police, '112'), (EmergencyKind.ambulance, '119'), (EmergencyKind.fire, '119')],
  'Indie': [(EmergencyKind.general, '112')],
  'Austrálie': [(EmergencyKind.general, '000'), (EmergencyKind.general, '112')],
  'Nový Zéland': [(EmergencyKind.general, '111')],
};
