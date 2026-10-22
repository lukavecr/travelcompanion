import 'package:flutter/material.dart';

const docTypes = <String, String>{
  'flight': 'Letenka',
  'hotel': 'Hotel',
  'train': 'Vlak',
  'bus': 'Autobus',
  'ferry': 'Trajekt',
  'ticket': 'Vstupenka',
  'insurance': 'Pojištění',
  'visa': 'Vízum',
  'other': 'Jiný doklad',
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
