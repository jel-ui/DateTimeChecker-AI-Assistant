import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens matching the web CSS custom properties.
class AppColors {
  // ── Light ──
  static const lightBg = Color(0xFFF6F8F4);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceSoft = Color(0xFFEDF5F1);
  static const lightText = Color(0xFF17312F);
  static const lightMuted = Color(0xFF6A7E7B);
  static const lightLine = Color(0xFFDCE7E2);
  static const lightPrimary = Color(0xFF0F766E);
  static const lightPrimaryDark = Color(0xFF095C56);
  static const lightPrimarySoft = Color(0xFFD8EFEA);
  static const lightAccent = Color(0xFFF59E0B);
  static const lightDanger = Color(0xFFBE3F4B);
  static const lightDangerSoft = Color(0xFFFCE8E8);

  // ── Dark ──
  static const darkBg = Color(0xFF102321);
  static const darkSurface = Color(0xFF17312F);
  static const darkSurfaceSoft = Color(0xFF1D3B38);
  static const darkText = Color(0xFFEDF9F5);
  static const darkMuted = Color(0xFFA5BBB7);
  static const darkLine = Color(0xFF31514D);
  static const darkPrimary = Color(0xFF55C6B9);
  static const darkPrimaryDark = Color(0xFF82DACE);
  static const darkPrimarySoft = Color(0xFF244B47);
  static const darkDanger = Color(0xFFFF8B94);
  static const darkDangerSoft = Color(0xFF4A2B30);
}

class AppTheme {
  AppTheme._();

  static const double radius = 22;
  static const double cardRadius = 22;
  static const double inputRadius = 11;
  static const double buttonRadius = 12;

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }

  // ── Light Theme ──
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.lightAccent,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
        error: AppColors.lightDanger,
        outline: AppColors.lightLine,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: AppColors.lightLine),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.lightLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.lightLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
        labelStyle: TextStyle(
          color: AppColors.lightMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightMuted,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }

  // ── Dark Theme ──
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBg,
        secondary: AppColors.lightAccent,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        error: AppColors.darkDanger,
        outline: AppColors.darkLine,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: AppColors.darkLine),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
        labelStyle: TextStyle(
          color: AppColors.darkMuted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBg,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkMuted,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

/// Extension to access semantic colors not in the default ColorScheme.
extension AppColorsExtension on ColorScheme {
  Color get surfaceSoft => brightness == Brightness.light
      ? AppColors.lightSurfaceSoft
      : AppColors.darkSurfaceSoft;
  Color get muted => brightness == Brightness.light
      ? AppColors.lightMuted
      : AppColors.darkMuted;
  Color get line => brightness == Brightness.light
      ? AppColors.lightLine
      : AppColors.darkLine;
  Color get primarySoft => brightness == Brightness.light
      ? AppColors.lightPrimarySoft
      : AppColors.darkPrimarySoft;
  Color get danger => brightness == Brightness.light
      ? AppColors.lightDanger
      : AppColors.darkDanger;
  Color get dangerSoft => brightness == Brightness.light
      ? AppColors.lightDangerSoft
      : AppColors.darkDangerSoft;
  Color get bg => brightness == Brightness.light
      ? AppColors.lightBg
      : AppColors.darkBg;
}
