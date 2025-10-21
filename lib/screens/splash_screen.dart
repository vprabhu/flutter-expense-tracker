import 'package:flutter/material.dart';
import 'dart:async';

// SplashScreen is a StatefulWidget because we use initState and trigger navigation after a delay
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Run a timer for 2 seconds, then navigate to the login screen
    Timer(Duration(seconds: 2), () {
      // Use named routing for professional, testable navigation
      Navigator.pushReplacementNamed(context, '/login');
      // Alternatively, for direct widget navigation, use:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold gives page structure, Center puts contents in the middle vertically/horizontally
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          children: [
            // App Icon or Logo (replace with your asset if you have one)
            Icon(
              Icons.account_balance_wallet,
              size: 90,
              color: Colors.blue[200], // Pastel blue like your mockup
            ),
            SizedBox(height: 24), // Gap between logo and text
            // App Name Text (bold, grey, nicely spaced)
            Text(
              'SmartSpends',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
