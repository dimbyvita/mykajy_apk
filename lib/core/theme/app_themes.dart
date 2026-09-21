import 'package:flutter/material.dart';

abstract class AppThemes {
  AppThemes._();

  // Seed colors per theme
  static const _lightSeed = Color(0xFF2D5BE3);
  static const _darkSeed = Color(0xFF7B93FF);
  static const _oceanSeed = Color(0xFF0891B2);
  static const _roseSeed = Color(0xFFBE185D);

  static ThemeData light() => _build(_lightSeed, Brightness.light);
  static ThemeData dark() => _build(_darkSeed, Brightness.dark);
  static ThemeData ocean() => _build(_oceanSeed, Brightness.light);
  static ThemeData rose() => _build(_roseSeed, Brightness.light);

  static ThemeData fromKey(String key) {
    switch (key) {
      case 'dark':
        return dark();
      case 'ocean':
        return ocean();
      case 'rose':
        return rose();
      default:
        return light();
    }
  }

  static ThemeData _build(Color seed, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF0F1119)
          : const Color(0xFFF5F7FA),
      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.dark
            ? const Color(0xFF1C2030)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: brightness == Brightness.dark
                ? const Color(0xFF2A3048)
                : const Color(0xFFE4E9F0),
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: brightness == Brightness.dark
            ? Colors.white
            : const Color(0xFF1A2B5C),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E9F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE4E9F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: seed, width: 1.5),
        ),
        filled: true,
        fillColor: brightness == Brightness.dark
            ? const Color(0xFF1C2030)
            : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brightness == Brightness.dark
              ? Colors.white54
              : const Color(0xFF7C8BA1),
          textStyle: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
        ),
      ),
    );
  }

  // Theme color helpers
  static Color expenseColor(BuildContext context) => const Color(0xFFE8561A);
  static Color incomeColor(BuildContext context) => const Color(0xFF1EAD6F);
  static Color navyColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1A2B5C);
  static Color mutedColor(BuildContext context) => const Color(0xFF7C8BA1);
  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C2030)
          : Colors.white;
  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A3048)
          : const Color(0xFFE4E9F0);
}
// TODO Implement this library.