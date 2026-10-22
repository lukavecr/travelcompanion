import 'package:flutter/material.dart';

enum FieldKind { text, multiline, date, phone, email }

class VaultField {
  const VaultField(this.key, this.label, [this.kind = FieldKind.text]);
  final String key;
  final String label;
  final FieldKind kind;
}

class VaultType {
  const VaultType({
    required this.key,
    required this.label,
    required this.icon,
    required this.fields,
    this.titleField,
    this.expiryField,
    this.warnBefore = const Duration(days: 30),
    this.remindDays = const [30, 7, 0],
    this.singleton = false,
  });
  final String key;
  final String label;
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

/// „za 6 měsíců“, „za 14 dní“, „zítra“, „dnes“.
String fmtDaysAhead(int days) {
  if (days <= 0) return 'dnes';
  if (days == 1) return 'zítra';
  if (days >= 60) {
    final m = (days / 30.4).round();
    return 'za $m ${m < 5 ? 'měsíce' : 'měsíců'}';
  }
  return 'za $days ${days < 5 ? 'dny' : 'dní'}';
}

/// Text pro formulář: kdy přijde upozornění.
String remindPlanText(VaultType t) {
  final before = t.remindDays
      .where((d) => d > 0)
      .map((d) => d == 1 ? '1 den' : fmtDaysAhead(d).replaceFirst('za ', ''));
  final onDay = t.remindDays.contains(0);
  return 'Upozorním ${before.join(', ')} předem${onDay ? ' a v den konce platnosti' : ''} (v 9:00).';
}

VaultType vaultType(String key) =>
    vaultTypes.firstWhere((t) => t.key == key, orElse: () => vaultTypes.last);
