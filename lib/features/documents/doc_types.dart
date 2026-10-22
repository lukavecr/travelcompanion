import 'package:flutter/material.dart';
import '../../l10n/tr.dart';

/// Názvy typů dokladů v jazyce aplikace (getter – mění se s jazykem).
Map<String, String> get docTypes => <String, String>{
  'flight': tr('Letenka'),
  'hotel': tr('Hotel'),
  'train': tr('Vlak'),
  'bus': tr('Autobus'),
  'ferry': tr('Trajekt'),
  'ticket': tr('Vstupenka'),
  'insurance': tr('Pojištění'),
  'visa': tr('Vízum'),
  'other': tr('Jiný doklad'),
};

const transportTypes = {'flight', 'train', 'bus', 'ferry'};

IconData docIcon(String type) {
  switch (type) {
    case 'flight':
      return Icons.flight;
    case 'hotel':
      return Icons.hotel;
    case 'train':
      return Icons.train;
    case 'bus':
      return Icons.directions_bus;
    case 'ferry':
      return Icons.directions_boat;
    case 'ticket':
      return Icons.confirmation_number;
    case 'insurance':
      return Icons.health_and_safety;
    case 'visa':
      return Icons.badge;
    default:
      return Icons.description;
  }
}
