import 'package:flutter/material.dart';

const placeTypes = <String, String>{
  'hotel': 'Hotel',
  'attraction': 'Atrakce',
  'restaurant': 'Restaurace',
  'transport': 'Doprava',
  'custom': 'Vlastní bod',
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
