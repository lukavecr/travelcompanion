import 'package:flutter/material.dart';
import '../../l10n/tr.dart';

/// Názvy kategorií v jazyce aplikace (getter – mění se s jazykem).
Map<String, String> get expenseCategories => <String, String>{
  'food': tr('Jídlo'),
  'transport': tr('Doprava'),
  'lodging': tr('Ubytování'),
  'attractions': tr('Atrakce'),
  'shopping': tr('Nákupy'),
  'other': tr('Ostatní'),
};

IconData categoryIcon(String c) {
  switch (c) {
    case 'food':
      return Icons.restaurant;
    case 'transport':
      return Icons.directions_transit;
    case 'lodging':
      return Icons.hotel;
    case 'attractions':
      return Icons.photo_camera;
    case 'shopping':
      return Icons.shopping_bag;
    default:
      return Icons.more_horiz;
  }
}

Color categoryColor(String c) {
  switch (c) {
    case 'food':
      return const Color(0xFFF5A623);
    case 'transport':
      return const Color(0xFF4FA3F7);
    case 'lodging':
      return const Color(0xFF9B7BEA);
    case 'attractions':
      return const Color(0xFF2DD4A7);
    case 'shopping':
      return const Color(0xFFE86A92);
    default:
      return const Color(0xFF8B98A8);
  }
}
