import 'package:flutter/material.dart';

import '../data/prefs/settings.dart';

/// Design tokens from the Hushbug UI Design System & Architecture Plan.
class HushbugColors {
  // Backgrounds
  static const Color background = Color(0xFF15131D);
  static const Color backgroundTop = Color(0xFF201C2C);
  static const Color backgroundBottom = Color(0xFF15131D);

  // Surface & Cards
  static const Color cardSurface = Color(0xFF201C2C);
  static const Color cardSurfaceElevated = Color(0xFF292338);
  static const Color cardBorder = Color(0xFF332C47);
  static const Color cardBorderSubtle = Color(0x337351D8);
  static const Color cardBorderActive = Color(0xFFA78BFA);

  // Primary Accent (Golden Yellow for CTA, highlights and rewards)
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentYellowLight = Color(0xFFFFE388);
  static const Color accentYellowDark = Color(0xFFE5B84A);
  static const Color onAccentYellow = Color(0xFF2C2106);

  // Brand Purples
  static const Color neonPurple = Color(0xFF7351D8);
  static const Color neonPurpleLight = Color(0xFFA78BFA);
  static const Color lavender = Color(0xFFA78BFA);
  static const Color neonPurpleDark = Color(0xFF4C1D95);
  static const Color glowPurple = Color(0x737351D8);

  // Semantic Status Colors
  static const Color imposterRed = Color(0xFFFF626B);
  static const Color imposterRedDark = Color(0xFFB91C1C);
  static const Color imposterBg = Color(0x2EFF626B);

  static const Color civilianEmerald = Color(0xFF62C99A);
  static const Color civilianEmeraldLight = Color(0xFF86E3B8);
  static const Color civilianBg = Color(0x2E62C99A);

  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color warningOrange = Color(0xFFFFD166);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF5F1FF);
  static const Color textSecondary = Color(0xFFAAA3B8);
  static const Color textSubtext = Color(0xFFAAA3B8);
  static const Color textMuted = Color(0xFF6F688B);

  // Ambient Radial Scaffold Gradient
  static const RadialGradient scaffoldGradient = RadialGradient(
    center: Alignment(0, -0.7),
    radius: 1.2,
    colors: [
      Color(0xFF2A2046),
      Color(0xFF15131D),
      Color(0xFF0E0D15),
    ],
  );

  // Golden Button Gradient
  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE388),
      Color(0xFFFFD166),
      Color(0xFFE5B84A),
    ],
  );

  // Neon Purple Button Gradient
  static const LinearGradient neonPurpleGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
    ],
  );
}

/// Six accent colours (all unlocked).
const accentColors = <Color>[
  Color(0xFF7351D8), // Hush violet
  Color(0xFF00A88E), // Mint
  Color(0xFFFF6E5A), // Coral
  Color(0xFFFFD166), // Sunflower
  Color(0xFF2F7BFF), // Ocean
  Color(0xFFE5487D), // Rose
];

ThemeData buildTheme(Brightness brightness, int accent, {bool amoled = false}) {
  final seed = accentColors[accent.clamp(0, accentColors.length - 1)];
  var scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
    surface: amoled ? Colors.black : HushbugColors.background,
    onSurface: HushbugColors.textPrimary,
    primary: HushbugColors.neonPurpleLight,
    onPrimary: Colors.white,
    secondary: HushbugColors.accentYellow,
    onSecondary: HushbugColors.onAccentYellow,
  );

  if (amoled) {
    scheme = scheme.copyWith(
      surface: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF0A0A0A),
      surfaceContainer: const Color(0xFF111111),
      surfaceContainerHigh: const Color(0xFF181818),
      surfaceContainerHighest: const Color(0xFF202020),
    );
  } else {
    scheme = scheme.copyWith(
      surface: HushbugColors.background,
      surfaceContainerLowest: HushbugColors.backgroundBottom,
      surfaceContainerLow: const Color(0xFF1A1626),
      surfaceContainer: HushbugColors.cardSurface,
      surfaceContainerHigh: HushbugColors.cardSurfaceElevated,
      surfaceContainerHighest: const Color(0xFF332C47),
    );
  }

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    scaffoldBackgroundColor: amoled ? Colors.black : HushbugColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: HushbugColors.textPrimary,
        letterSpacing: 0.2,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: HushbugColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: HushbugColors.cardBorder, width: 1.2),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: HushbugColors.neonPurple,
        foregroundColor: Colors.white,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        side: const BorderSide(color: HushbugColors.cardBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: HushbugColors.textSecondary,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: HushbugColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: HushbugColors.cardBorder, width: 1),
      labelStyle: const TextStyle(color: HushbugColors.textSecondary, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1B162E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: HushbugColors.cardBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: HushbugColors.cardBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: HushbugColors.cardBorderActive, width: 2),
      ),
    ),
  );
}

ThemeMode toThemeMode(AppThemeMode m) => switch (m) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark || AppThemeMode.amoled => ThemeMode.dark,
    };
