import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const lightBackground = Colors.white;
  static const darkBackground = Color(0xFF545974);
  static const accentColor = Color(0xFFFF6464);
  static const lightTextColor = Color(0xFF545974);
  static const darkTextColor = Colors.white;

  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: accentColor,
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: 48,
          color: lightTextColor,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: lightTextColor.withOpacity(0.7),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: const BorderSide(color: accentColor),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: accentColor,
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'BebasNeue',
          fontSize: 48,
          color: darkTextColor,
          letterSpacing: 1.2,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: darkTextColor.withOpacity(0.7),
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: const BorderSide(color: accentColor),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}