import 'package:flutter/material.dart';


/// Design tokens from the Hushbug UI Design System & Architecture Plan.
class HushbugColors {
  // Backgrounds
  static const Color background = Color(0xFF160B30);
  static const Color backgroundTop = Color(0xFF2A1650);
  static const Color backgroundBottom = Color(0xFF140A2C);

  // Surface & Cards
  static const Color cardSurface = Color(0xFF26174A);
  static const Color cardSurfaceElevated = Color(0xFF311E5E);
  static const Color cardBorder = Color(0xFF4A3388);
  static const Color cardBorderSubtle = Color(0x59BE96FF);
  static const Color cardBorderActive = Color(0xFFD9C2FF);

  // Primary Accent (Golden Yellow for CTA, highlights and rewards)
  static const Color accentYellow = Color(0xFFFFC61A);
  static const Color accentYellowLight = Color(0xFFFFE680);
  static const Color accentYellowDark = Color(0xFFD08F00);
  static const Color onAccentYellow = Color(0xFF2B1B00);

  // Brand Purples
  static const Color neonPurple = Color(0xFF7C45F0);
  static const Color neonPurpleLight = Color(0xFFC9A4FF);
  static const Color lavender = Color(0xFFC9A4FF);
  static const Color neonPurpleDark = Color(0xFF4520A8);
  static const Color glowPurple = Color(0x8CA06BFF);

  // Semantic Status Colors
  static const Color imposterRed = Color(0xFFFF5A78);
  static const Color imposterRedDark = Color(0xFFB91C1C);
  static const Color imposterBg = Color(0x33FF5A78);

  static const Color civilianEmerald = Color(0xFF3FD98A);
  static const Color civilianEmeraldLight = Color(0xFF86E3B8);
  static const Color civilianBg = Color(0x333FD98A);

  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color warningOrange = Color(0xFFFFC61A);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF5F1FF);
  static const Color textSecondary = Color(0xFFD3C2F2);
  static const Color textSubtext = Color(0xFFCBB8EE);
  static const Color textMuted = Color(0xFFA592CF);

  // Ambient Radial Scaffold Gradient
  static const RadialGradient scaffoldGradient = RadialGradient(
    center: Alignment(0, -0.45),
    radius: 1.1,
    colors: [
      Color(0xFF4A2585),
      Color(0xFF23124A),
      Color(0xFF140A2C),
    ],
  );

  // Golden Button Gradient
  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE680),
      Color(0xFFFFC61A),
    ],
  );

  // Neon Purple Button Gradient
  static const LinearGradient neonPurpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF9B6BFF),
      Color(0xFF6C3BE6),
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
    fontFamily: 'Nunito',
  );
  // Fredoka for headings, timers and scores; Nunito for everything else.
  final text = base.textTheme.copyWith(
    displayLarge: base.textTheme.displayLarge?.copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.w700),
    displayMedium: base.textTheme.displayMedium?.copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.w700),
    displaySmall: base.textTheme.displaySmall?.copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.w600),
    headlineLarge: base.textTheme.headlineLarge?.copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.w600),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.w600),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.w600),
    titleLarge: base.textTheme.titleLarge?.copyWith(fontFamily: 'Fredoka', fontWeight: FontWeight.w600),
  );
  final glassShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(28),
    side: const BorderSide(color: HushbugColors.cardBorder, width: 1.5),
  );

  return base.copyWith(
    textTheme: text,
    dialogTheme: DialogThemeData(
      backgroundColor: HushbugColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: glassShape,
      titleTextStyle: const TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w600, color: HushbugColors.textPrimary),
      contentTextStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w600, color: HushbugColors.textSecondary),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: HushbugColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: HushbugColors.cardBorder,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: HushbugColors.cardSurfaceElevated,
      contentTextStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w700, color: HushbugColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: HushbugColors.cardBorder)),
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? HushbugColors.accentYellow : HushbugColors.textMuted),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? HushbugColors.neonPurple : HushbugColors.cardSurfaceElevated),
      trackOutlineColor: const WidgetStatePropertyAll(HushbugColors.cardBorder),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? HushbugColors.neonPurple : HushbugColors.cardSurface),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        side: const WidgetStatePropertyAll(BorderSide(color: HushbugColors.cardBorder)),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: HushbugColors.neonPurpleLight,
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    listTileTheme: const ListTileThemeData(iconColor: HushbugColors.neonPurpleLight, textColor: HushbugColors.textPrimary),
    sliderTheme: const SliderThemeData(activeTrackColor: HushbugColors.accentYellow, thumbColor: HushbugColors.accentYellow, inactiveTrackColor: HushbugColors.cardSurfaceElevated),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: HushbugColors.neonPurpleLight),
    scaffoldBackgroundColor: amoled ? Colors.black : HushbugColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: base.textTheme.titleLarge?.copyWith(
        fontFamily: 'Fredoka',
        fontWeight: FontWeight.w600,
        color: HushbugColors.textPrimary,
        letterSpacing: 0.2,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: HushbugColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: HushbugColors.cardBorder, width: 1.5),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        textStyle: const TextStyle(fontFamily: 'Fredoka', fontSize: 17, fontWeight: FontWeight.w600),
        shape: const StadiumBorder(),
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
      fillColor: const Color(0xFF1E1140),
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

