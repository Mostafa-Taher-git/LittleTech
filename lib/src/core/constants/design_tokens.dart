import 'package:flutter/material.dart';

/// LittleTech Design System V3 — Tokens
///
/// Spacing, radius, shadows, and category colors extracted from the
/// official design system. Use these instead of hardcoded values.
class Spacing {
  Spacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 6;
  static const double sm = 8;
  static const double m = 10;
  static const double ms = 12;
  static const double ml = 14;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double xxl2 = 32;
  static const double xxxl = 36;
  static const double xxxl2 = 40;
  static const double xxxxl = 48;
  static const double xxxxxl = 60;
}

class Radii {
  Radii._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double s = 6;
  static const double sm = 8;
  static const double ms = 10;
  static const double md = 12;
  static const double ml = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 20;
  static const double pill = 999;
}

class AppShadows {
  AppShadows._();
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x120F2B2E), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x1A0F2B2E), blurRadius: 22, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x260F2B2E), blurRadius: 44, offset: Offset(0, 20)),
  ];
}

/// 14 unique category colors — one per category, used for map nodes,
/// chips, and boss encounters. Each color belongs to exactly one category.
class CategoryColors {
  CategoryColors._();

  static const Color coreComponents = Color(0xFFE5484D);
  static const Color ram = Color(0xFF17B2C4);
  static const Color operatingSystem = Color(0xFF0FAE85);
  static const Color audio = Color(0xFFF2994A);
  static const Color peripherals = Color(0xFFE8B330);
  static const Color software = Color(0xFF8B5CF6);
  static const Color internet = Color(0xFF2E90D9);
  static const Color storage = Color(0xFF9CA82C);
  static const Color display = Color(0xFFD6449A);
  static const Color mobile = Color(0xFF8BC53F);
  static const Color gaming = Color(0xFFF0407A);
  static const Color smartHome = Color(0xFF5B7FE0);
  static const Color security = Color(0xFF43A047);
  static const Color networking = Color(0xFFA64DC9);

  /// Returns the color for a given category id.
  static Color forId(String id) => switch (id) {
    'core_components' => coreComponents,
    'ram' => ram,
    'operating_system' => operatingSystem,
    'audio' => audio,
    'peripherals' => peripherals,
    'software' => software,
    'internet' => internet,
    'storage' => storage,
    'display' => display,
    'mobile' => mobile,
    'gaming' => gaming,
    'smart_home' => smartHome,
    'security' => security,
    'networking' => networking,
    _ => const Color(0xFF8FC4C2),
  };

  /// Returns the color for a boss visual type (1-14).
  static Color forVisualType(int type) => switch (type) {
    1 => coreComponents,
    2 => ram,
    3 => operatingSystem,
    4 => audio,
    5 => peripherals,
    6 => software,
    7 => internet,
    8 => storage,
    9 => display,
    10 => mobile,
    11 => gaming,
    12 => smartHome,
    13 => security,
    14 => networking,
    _ => const Color(0xFF8FC4C2),
  };
}

/// Rarity colors matching the reward pool tiers.
class RarityColors {
  RarityColors._();
  static const Color common = Color(0xFF8A94A6);
  static const Color rare = Color(0xFF3B82F6);
  static const Color epic = Color(0xFFA855F7);
  static const Color legendary = Color(0xFFE3B93C);
}
