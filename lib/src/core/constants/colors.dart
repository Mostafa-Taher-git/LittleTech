import 'package:flutter/material.dart';

export 'design_tokens.dart';

class AppColors {
  // Core palette — V3 Design System
  static const Color primary = Color(0xFF1F6E77); // Circuit Teal
  static const Color onPrimary = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFFE3B93C); // Molten Gold
  static const Color accent = secondary; // Alias
  static const Color onAccent = Color(0xFF0F2B2E); // Deep Ink
  static const Color onSecondary = onAccent; // Alias

  static const Color error = Color(0xFFC4432E); // Ember
  static const Color success = Color(0xFF3A8451); // Success

  // Neutrals
  static const Color background = Color(0xFFEAF4F4); // Mist
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFD4ECEE);
  static const Color onSurface = Color(0xFF0F2B2E); // Deep Ink
  static const Color onSurfaceMuted = Color(0xFF4A7A7E);

  // Borders / dividers
  static const Color border = Color(0xFFB8D8DC);
  static const Color divider = Color(0xFFD4ECEE);

  // Feedback
  static const Color warning = Color(0xFFB45309);
  static const Color info = Color(0xFF0E7490);

  // Trace — circuit path lines
  static const Color trace = Color(0xFF8FC4C2);

  // Gradient helpers
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F2B2E), Color(0xFF0A1A1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE3B93C), Color(0xFFC9A030)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
