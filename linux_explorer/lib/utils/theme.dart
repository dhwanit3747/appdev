import 'package:flutter/material.dart';

class AppTheme {
  static const Color purple = Color(0xFF7B3FE4);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: purple,
    scaffoldBackgroundColor: const Color(0xFFF6F1FF),
    appBarTheme: const AppBarTheme(
      backgroundColor: purple,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: purple,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: purple,
    scaffoldBackgroundColor: const Color(0xFF0F061E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C0F3A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: purple,
      brightness: Brightness.dark,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E133F),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
