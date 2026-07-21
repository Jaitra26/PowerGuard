import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Color Tokens
  static const Color background = Color(0xFF0D1322);
  static const Color surface = Color(0xFF0D1322);
  static const Color surfaceContainerLow = Color(0xFF151B2B);
  static const Color surfaceContainer = Color(0xFF191F2F);
  static const Color surfaceContainerHigh = Color(0xFF242A3A);
  static const Color surfaceContainerHighest = Color(0xFF2F3445);
  static const Color onSurface = Color(0xFFDDE2F8);
  static const Color onSurfaceVariant = Color(0xFFB9CCB2);
  static const Color primary = Color(0xFF00E639); // Electric Green
  static const Color primaryContainer = Color(0xFF00FF41);
  static const Color onPrimary = Color(0xFF000000);
  static const Color outline = Color(0xFF84967E);
  static const Color outlineVariant = Color(0xFF3B4B37);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF00FF41);

  // Status Colors
  static const Color statusNormal = Color(0xFF00FF41);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusCritical = Color(0xFFEF4444);

  // Font getters to handle dynamic fallback
  static TextStyle geistMonoStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0.5,
    Color? color,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color ?? onSurface,
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    final customTextTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
      headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, color: onSurface),
      headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: onSurface),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: onSurface),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, color: onSurface),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w400, color: onSurfaceVariant),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500, color: onSurface),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: onSurfaceVariant),
      labelSmall: GoogleFonts.inter(fontWeight: FontWeight.w400, color: onSurfaceVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        surfaceContainerHighest: surfaceContainer,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
        onError: onPrimary,
      ),
      textTheme: customTextTheme,
      cardTheme: CardThemeData(
        color: surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        floatingLabelStyle: const TextStyle(color: primary),
        labelStyle: const TextStyle(color: onSurfaceVariant),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
        border: const UnderlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
          borderSide: BorderSide(color: outlineVariant, width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
          borderSide: BorderSide(color: primary, width: 2.0),
        ),
        errorBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
          borderSide: BorderSide(color: error, width: 1.0),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
          borderSide: BorderSide(color: error, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const StadiumBorder(),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLow,
        elevation: 0,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: onSurfaceVariant),
        selectedLabelStyle: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(color: onSurfaceVariant, fontSize: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
