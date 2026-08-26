import 'package:club_fitness/core/utils/utils.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Colors extracted from logo
  static const Color primary = Color(0xFFC41E2D);
  static const Color secondary = Color(0xFFFFFFFF);

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);

  static const Color card = Color(0xFF222222);
  static const Color cardBorder = Color(0xFF333333);
  static const Color divider = Color(0xFF333333);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    ),

    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: primary, width: 2),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: Colors.grey,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),

    dividerColor: Colors.white12,

    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: const TextStyle(color: textPrimary),
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
    ),

    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );

  static Color clampColor(int index) =>
      palette[Randomizer.clampInt(index, palette.length)];

  static Color get randomColor => palette[randomColorIndex];

  static int get randomColorIndex => Randomizer.randomNumber(palette.length);

  static const List<Color> palette = [
    Color(0xFFEF4444), // red
    Color(0xFF0EA5E9), // sky
    Color(0xFF22C55E), // green
    Color(0xFFD946EF), // fuchsia
    Color(0xFFF59E0B), // amber
    Color(0xFF1E3A5F), // darkBlue
    Color(0xFF10B981), // emerald
    Color(0xFF7C3AED), // deepPurple
    Color(0xFFF97316), // orange
    Color(0xFF0891B2), // cyan700
    Color(0xFFA855F7), // purple
    Color(0xFF14532D), // green900
    Color(0xFFEC4899), // pink
    Color(0xFF3B82F6), // blue
    Color(0xFF65A30D), // lime
    Color(0xFF4F46E5), // indigo
    Color(0xFF14B8A6), // teal
    Color(0xFFEA580C), // deepOrange
    Color(0xFF8B5CF6), // violet
    Color(0xFF06B6D4), // cyan
    // Added colors
    Color(0xFFDC2626), // red700
    Color(0xFF2563EB), // blue600
    Color(0xFF16A34A), // green600
    Color(0xFFE11D48), // rose
    Color(0xFFCA8A04), // yellow700
    Color(0xFF9333EA), // purple600
    Color(0xFF0F766E), // teal700
    Color(0xFFBE123C), // rose700
    Color(0xFF4338CA), // indigo700
    Color(0xFF84CC16), // lime500
    Color(0xFF0284C7), // lightBlue700
    Color(0xFFB45309), // amber700
    Color(0xFFC026D3), // fuchsia600
    Color(0xFF059669), // emerald600
    Color(0xFF7E22CE), // purple700
    Color(0xFF166534), // green800
    Color(0xFFDB2777), // pink600
    Color(0xFF0369A1), // sky700
    Color(0xFF9A3412), // orange800
    Color(0xFF4D7C0F), // lime700
  ];
}

extension AlphaConvertorExtension on double {
  int get opacityToAlpha => (this * 255).round();
}

extension OpacityConvertorExtension on Color {
  Color withAOpacity(double opacity) {
    return withAlpha(opacity.opacityToAlpha);
  }
}

extension ColorConvertorExtension on String {
  Color get fromHex {
    final buffer = StringBuffer();
    if (length == 6 || length == 7) buffer.write('ff');
    buffer.write(replaceAll('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension ColorFormatting on Color {
  /// Returns hex string. If [includeAlpha] is true returns AARRGGBB, else RRGGBB.
  String toHex({bool includeAlpha = false, bool leadingHashSign = true}) {
    if (includeAlpha) {
      final argb = toARGB32();
      final hex = argb.toRadixString(16).padLeft(8, '0').toUpperCase();
      return (leadingHashSign ? '#' : '') + hex;
    } else {
      final rgb =
          ((r * 255).round() << 16) |
          ((g * 255).round() << 8) |
          (b * 255).round();
      final hex = rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
      return (leadingHashSign ? '#' : '') + hex;
    }
  }

  int get toRed => (r * 255).round();
  int get toGreen => (g * 255).round();
  int get toBlue => (b * 255).round();
}
