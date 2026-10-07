// Defines the visual identity used across the app.
// This file centralizes the color palette, typography, and Material styling so
// every screen stays consistent and matches the SmartMove brand.
import 'package:flutter/material.dart';

// AppTheme contains the app's default color palette and themed styling rules.
class AppTheme {
  // Deep green used for most text and dark surfaces.
  static const ink = Color(0xFF14221F);

  // Primary brand color for buttons, highlights and key actions.
  static const teal = Color(0xFF167D73);

  // Secondary accent color used for emphasis or warning states.
  static const coral = Color(0xFFE96F51);

  // Soft neutral background shade used on screens and cards.
  static const mist = Color(0xFFF3F7F4);

  // The light theme configuration used throughout the app.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: mist,
        colorScheme: ColorScheme.fromSeed(seedColor: teal)
            .copyWith(primary: teal, secondary: coral, surface: Colors.white, onSurface: ink),
        fontFamily: 'Trebuchet MS',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: ink),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF52635E)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDCE7E2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: teal, width: 2),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE1EBE6)),
          ),
        ),
      );
}