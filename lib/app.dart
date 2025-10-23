import 'package:expense_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'nav.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class SmartSpendsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSpends',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // First screen
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => SignInScreen(),
        // '/home': (context) => HomeScreen(),
      },
    );
  }
}


// ExpensesApp: The root MaterialApp with custom theme using blue shades
class ExpensesApp extends StatelessWidget {
  const ExpensesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const NavBar(), // Updated to use MainScreen for navigation structure
    );
  }
}