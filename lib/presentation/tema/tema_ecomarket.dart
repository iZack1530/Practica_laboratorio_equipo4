import 'package:flutter/material.dart';

/// Tema Material 3 de EcoMarket generado a partir de un color semilla.
abstract final class TemaEcoMarket {
  static const Color _colorSemilla = Color(0xFF2E7D32);

  static ThemeData get claro => _construir(Brightness.light);

  static ThemeData get oscuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final esquema = ColorScheme.fromSeed(seedColor: _colorSemilla, brightness: brillo);
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), isDense: true),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
