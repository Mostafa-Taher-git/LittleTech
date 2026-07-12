import 'package:flutter/material.dart';

/// LittleTech Design System V3 — Tokens
///
/// Spacing, radius, shadows, and category colors extracted from the
/// official design system. Use these instead of hardcoded values.

/// Spacing scale — 8 tokens consolidating the 15 original values.
class Spacing {
  Spacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double ms = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xl2 = 32;
  static const double xl3 = 48;
}

/// Radius scale — V3 spec.
class Radii {
  Radii._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xxl = lg; // Alias for compatibility
  static const double pill = 999;
}

/// Elevation shadows — V3 spec.
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

/// 14 unique category colors — everyday variants for light UI backgrounds.
/// Boss encounters use the brighter variants via [CategoryColors.forBoss].
class CategoryColors {
  CategoryColors._();

  // Everyday (light UI) colors — deepened for chips, map nodes, icons
  static const Color coreComponents = Color(0xFF95232C);
  static const Color ram = Color(0xFF238495);
  static const Color operatingSystem = Color(0xFF23956B);
  static const Color audio = Color(0xFF955823);
  static const Color peripherals = Color(0xFF957E23);
  static const Color software = Color(0xFF322395);
  static const Color internet = Color(0xFF236395);
  static const Color storage = Color(0xFF739523);
  static const Color display = Color(0xFF95236B);
  static const Color mobile = Color(0xFF239532);
  static const Color gaming = Color(0xFF953A23);
  static const Color smartHome = Color(0xFF233295);
  static const Color security = Color(0xFF439523);
  static const Color networking = Color(0xFF782395);

  // Boss encounter (dark UI) colors — higher saturation/lightness
  static const Color coreComponentsBoss = Color(0xFFDD2C3B);
  static const Color ramBoss = Color(0xFF2CC2DD);
  static const Color operatingSystemBoss = Color(0xFF2CDD9C);
  static const Color audioBoss = Color(0xFFDD7F2C);
  static const Color peripheralsBoss = Color(0xFFDDB92C);
  static const Color softwareBoss = Color(0xFF442CDD);
  static const Color internetBoss = Color(0xFF2C90DD);
  static const Color storageBoss = Color(0xFFA8DD2C);
  static const Color displayBoss = Color(0xFFDD2C9C);
  static const Color mobileBoss = Color(0xFF2CDD44);
  static const Color gamingBoss = Color(0xFFDD502C);
  static const Color smartHomeBoss = Color(0xFF2C44DD);
  static const Color securityBoss = Color(0xFF5EDD2C);
  static const Color networkingBoss = Color(0xFFB12CDD);

  /// Returns the everyday color for a given category id.
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

  /// Returns the everyday color for a boss visual type (1-14).
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

  /// Returns the boss encounter color for a boss visual type (1-14).
  static Color forBoss(int type) => switch (type) {
        1 => coreComponentsBoss,
        2 => ramBoss,
        3 => operatingSystemBoss,
        4 => audioBoss,
        5 => peripheralsBoss,
        6 => softwareBoss,
        7 => internetBoss,
        8 => storageBoss,
        9 => displayBoss,
        10 => mobileBoss,
        11 => gamingBoss,
        12 => smartHomeBoss,
        13 => securityBoss,
        14 => networkingBoss,
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
