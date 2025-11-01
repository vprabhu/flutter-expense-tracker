import 'package:expense_tracker/models/home_arguments.dart';
import 'package:flutter/material.dart';

import 'bottom_nav.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

class SmartSpendsApp extends StatelessWidget {
  const SmartSpendsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartSpends',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Splash screen
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const SignInScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as HomeArguments;
          return NavBar(
            user: args.user,
            authService: args.authService,
          );
        }
      },
    );
  }
}
