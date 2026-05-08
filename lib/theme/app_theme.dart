import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFC79E75);
  static const Color accentColor = Color(0xFFDFB68F);
  static const Color goldBorder = Color(0xFFE5D5C5);
  static const Color successColor = Color(0xFF8BAA79);
  static const Color warnColor = Color(0xFFD6A054);
  static const Color dangerColor = Color(0xFFD9725C);

  static const Color scaffoldBackground = Color(0xFFF9F6F0);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFF2EBE1);
  static const Color surfaceLight = Color(0xFFEBDDCC);

  static const Color textPrimary = Color(0xFF2C241B);
  static const Color textSecondary = Color(0xFF6B5A4B);
  static const Color textMuted = Color(0xFF9E8D7B);

  static const Color primaryLight = Color(0xFFE5D0BC);
  static const Color temperatureColor = Color(0xFFD98E5C);
  static const Color humidityColor = Color(0xFF7BA6BD);
  static const Color lightColor = Color(0xFFE1B862);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9F6F0), Color(0xFFF3EFE9), Color(0xFFEBE6DF)],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC79E75), Color(0xFFB5895D)],
  );

  static BoxDecoration panelDecoration({double blur = 20}) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xFFEAE2D6),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: blur,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackground,
      cardColor: cardBackground,
      canvasColor: scaffoldBackground,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.manropeTextTheme(
        base.textTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      primaryTextTheme: GoogleFonts.manropeTextTheme(
        base.primaryTextTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          fontFamily: GoogleFonts.manrope().fontFamily,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9F6F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5D5C5), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5D5C5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
      ),
    );
  }
}
