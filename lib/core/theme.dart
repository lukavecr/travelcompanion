import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF2DD4A7);

  static ThemeData _build(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: b),
        // velké dotykové plochy pro ovládání jednou rukou
        materialTapTargetSize: MaterialTapTargetSize.padded,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      );

  static final dark = _build(Brightness.dark);
  static final light = _build(Brightness.light);
}
