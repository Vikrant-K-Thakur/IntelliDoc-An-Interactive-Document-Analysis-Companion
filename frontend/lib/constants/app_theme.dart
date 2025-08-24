import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF4A6FA5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4A6FA5),
      secondary: Color(0xFF6B8CBE),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF5F7FA),
      error: Color(0xFFE57373),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF4A6FA5),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black87,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(0xFF4A6FA5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textTheme: ButtonTextTheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF4A6FA5),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4A6FA5),
      secondary: Color(0xFF6B8CBE),
      surface: Color(0xFF121212),
      background: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
    ),
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF121212),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.white70,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: const Color(0xFF4A6FA5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textTheme: ButtonTextTheme.primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

