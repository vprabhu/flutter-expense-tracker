import 'package:flutter/material.dart';

class AppTheme {
  /* ----------------------------------------------------------
     Main swatch – you can change lightness here and the whole
     app follows automatically
     ---------------------------------------------------------- */
  static const MaterialColor blueSwatch = MaterialColor(
    0xFF1565C0, // primary blue
    <int, Color>{
      50:  Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5),
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );

  static ThemeData get blueTheme => ThemeData(
    primarySwatch: blueSwatch,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF1565C0)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF546E7A)),
    ),
  );
}