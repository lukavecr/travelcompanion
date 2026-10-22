import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/format.dart';
import '../../l10n/tr.dart';

enum FieldKind { text, multiline, date, phone, email }

class VaultField {
  const VaultField(this.key, this._label, [this.kind = FieldKind.text]);
  final String key;
  final String _label; // český text = klíč překladu
  String get label => tr(_label);
  final FieldKind kind;
}

class VaultType {
  const VaultType({
    required this.key,
    required String label,
    required this.icon,
    required this.fields,
    this.titleField,
    this.expiryField,
    this.warnBefore = const Duration(days: 30),
    this.remindDays = const [30, 7, 0],
    this.singleton = false,
  }) : _label = label; // ignore: prefer_initializing_formals
  final String key;
  final String _label; // český text = klíč překladu
  String get label => tr(_label);
  final IconData icon;
  final List<VaultField> fields;
  final String? titleField; // pole, které se ukáže jako název v seznamu
  final String? expiryField; // pole s datem platnosti
  final Duration warnBefore; // kdy začít upozorňovat na konec platnosti (barva v seznamu)
  final List<int> remindDays; // notifikace: kolik dní před koncem platnosti (0 = v den konce)
  final bool singleton; // jen jedna položka (zdravotní údaje)
}

const _note = VaultField('note', 'Poznámka', FieldKind.multiline);

/// Pořadí = pořadí sekcí ve Vaultu.
const vaultTypes = <VaultType>[
  VaultType(
    key: 'passport',
    label: 'Pas',
    icon: Icons.badge_outlined,
    titleField: 'name',
    expiryField: 'validUntil',
    // řada zemí chce pas platný ještě 6 měsíců po příjezdu
    warnBefore: Duration(days: 183),
    remindDays: [183, 90, 30, 0],
    fields: [
      VaultField('name', 'Jméno a příjmení'),
      VaultField('number', 'Číslo pasu'),
      VaultField('nationality', 'Státní občanství'),
      VaultField('birthDate', 'Datum narození', FieldKind.date),
      VaultField('issued', 'Datum vydání', FieldKind.date),
      VaultField('validUntil', 'Platnost do', FieldKind.date),
      _note,
    ],
  ),
  VaultType(
    key: 'visa',
    label: 'Víza',
    icon: Icons.approval_outlined,
    titleField: 'country',
    expiryField: 'validUntil',
    warnBefore: Duration(days: 14),
    remindDays: [14, 3, 1, 0],
    fields: [
      VaultField('country', 'Země'),
      VaultField('kind', 'Typ víza (turistické, e-visa…)'),
      VaultField('number', 'Číslo víza / žádosti'),
      VaultField('entries', 'Počet vstupů'),
      VaultField('validFrom', 'Platné od', FieldKind.date),
      VaultField('validUntil', 'Platnost do', FieldKind.date),
      VaultField('maxStay', 'Max. délka pobytu'),
      _note,
    ],
  ),
  VaultType(
    key: 'insurance',
    label: 'Pojištění',
    icon: Icons.health_and_safety_outlined,
    titleField: 'company',
    expiryField: 'validUntil',
    remindDays: [30, 7, 1, 0],
    fields: [
      VaultField('company', 'Pojišťovna'),
      VaultField('policy', 'Číslo smlouvy'),
      VaultField('assistance', 'Asistenční linka 24/7', FieldKind.phone),
      VaultField('email', 'E-mail asistence', FieldKind.email),
      VaultField('validFrom', 'Platné od', FieldKind.date),
      VaultField('validUntil', 'Platnost do', FieldKind.date),
      _note,
    ],
  ),
  VaultType(
    key: 'vaccination',
    label: 'Očkování',
    icon: Icons.vaccines_outlined,
    titleField: 'vaccine',
    expiryField: 'validUntil',
    fields: [
      VaultField('vaccine', 'Očkování (např. žlutá zimnice)'),
      VaultField('date', 'Datum očkování', FieldKind.date),
      VaultField('validUntil', 'Platnost do', FieldKind.date),
      VaultField('batch', 'Šarže / certifikát'),
      _note,
    ],
  ),
  VaultType(
    key: 'id',
    label: 'Další doklady',
    icon: Icons.credit_card_outlined,
    titleField: 'kind',
    expiryField: 'validUntil',
    fields: [
      VaultField('kind', 'Doklad (občanka, řidičák, mezinárodní řidičák…)'),
      VaultField('number', 'Číslo'),
      VaultField('validUntil', 'Platnost do', FieldKind.date),
      _note,
    ],
  ),
  VaultType(
    key: 'contact',
    label: 'Nouzové kontakty',
    icon: Icons.contact_phone_outlined,
    titleField: 'name',
    fields: [
      VaultField('name', 'Jméno'),
      VaultField('relation', 'Vztah (manželka, bratr…)'),
      VaultField('phone', 'Telefon (s předvolbou, např. +420…)', FieldKind.phone),
      VaultField('email', 'E-mail', FieldKind.email),
      _note,
    ],
  ),
  VaultType(
    key: 'medical',
    label: 'Zdravotní údaje',
    icon: Icons.medical_information_outlined,
    singleton: true,
    fields: [
      VaultField('name', 'Jméno a příjmení'),
      VaultField('birthDate', 'Datum narození', FieldKind.date),
      VaultField('bloodType', 'Krevní skupina (např. A+)'),
      VaultField('allergies', 'Alergie (anglicky)', FieldKind.multiline),
      VaultField('medications', 'Léky, které užívám (anglicky)', FieldKind.multiline),
      VaultField('conditions', 'Nemoci / diagnózy (anglicky)', FieldKind.multiline),
      VaultField('doctor', 'Můj lékař (jméno, telefon)'),
      _note,
    ],
  ),
];

/// Délka „6 měsíců“, „14 dní“, „3 dny“, „1 den“ (česká množná čísla; v jiných jazycích stačí 2 tvary).
String fmtDuration(int days) {
  if (days >= 60) {
    final m = (days / 30.4).round();
    return m < 5 ? tr('{n} měsíce', {'n': m}) : tr('{n} měsíců', {'n': m});
  }
  if (days == 1) return tr('1 den');
  return days < 5 ? tr('{n} dny', {'n': days}) : tr('{n} dní', {'n': days});
}

/// „za 6 měsíců“, „za 14 dní“, „zítra“, „dnes“.
String fmtDaysAhead(int days) {
  if (days <= 0) return tr('dnes');
  if (days == 1) return tr('zítra');
  return tr('za {duration}', {'duration': fmtDuration(days)});
}

/// Text pro formulář: kdy přijde upozornění.
String remindPlanText(VaultType t) {
  final before = t.remindDays.where((d) => d > 0).map(fmtDuration).join(', ');
  final time = fmtTime(AppSettings.instance.expiryReminderMinutes);
  return t.remindDays.contains(0)
      ? tr('Upozorním {before} předem a v den konce platnosti ({time}).',
          {'before': before, 'time': time})
      : tr('Upozorním {before} předem ({time}).', {'before': before, 'time': time});
}

VaultType vaultType(String key) =>
    vaultTypes.firstWhere((t) => t.key == key, orElse: () => vaultTypes.last);
