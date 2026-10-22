import 'package:flutter/material.dart';
import '../../l10n/tr.dart';

/// Názvy typů míst v jazyce aplikace (getter – mění se s jazykem).
Map<String, String> get placeTypes => <String, String>{
  'hotel': tr('Hotel'),
  'attraction': tr('Atrakce'),
  'restaurant': tr('Restaurace'),
  'transport': tr('Doprava'),
  'custom': tr('Vlastní bod'),
};

IconData placeIcon(String type) {
  switch (type) {
    case 'hotel':
      return Icons.hotel;
    case 'attraction':
      return Icons.photo_camera;
    case 'restaurant':
      return Icons.restaurant;
    case 'transport':
      return Icons.directions_transit;
    default:
      return Icons.place;
  }
}
