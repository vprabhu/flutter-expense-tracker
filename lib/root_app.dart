import 'package:expense_tracker/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'bottom_nav.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

class SmartSpendsApp extends StatelessWidget {
  const SmartSpendsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSpends',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Splash screen
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => SignInScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return NavBar(
            user: args['user'],
            authService: args['authService'],
          );
        }
      },
    );
  }
}
