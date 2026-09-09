import 'package:flutter/material.dart';

// TODO(T0.4): integrate material_3_expressive tokens here.
// Stub: standard Material 3 theme until M3E token layer is wired.

ThemeData theatreTheme({Brightness brightness = Brightness.dark}) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorSchemeSeed: const Color(0xFF6750A4),
  );
}
