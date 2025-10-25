import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnBackground = Color(0xFF374151);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFE5E7EB);

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        background: lightBackground,
        onSurface: lightOnSurface,
        onBackground: lightOnBackground,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: lightOnSurface,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: lightOnSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: lightOnBackground,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightOnBackground,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: lightOnBackground,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        background: darkBackground,
        onSurface: darkOnSurface,
        onBackground: darkOnBackground,
        error: errorColor,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkOnBackground,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkOnBackground,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkOnBackground,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
    );
  }

  // Gradient decorations
  static BoxDecoration get primaryGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryColor, secondaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration get successGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [successColor, Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration get warningGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [warningColor, Color(0xFFD97706)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static BoxDecoration get errorGradient => const BoxDecoration(
    gradient: LinearGradient(
      colors: [errorColor, Color(0xFFDC2626)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Border radius
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 24.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;
}
