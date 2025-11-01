import 'package:expense_tracker/models/home_arguments.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../services/auth_service.dart';

/// A splash screen that shows the app logo and name while checking the user's
/// authentication status. It navigates to the home screen if the user is logged in,
/// or to the login screen otherwise.

// SplashScreen is a StatefulWidget because it manages its own state, specifically
// the navigation logic that runs after a short delay.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // The initState method is called once when the widget is inserted into the widget tree.
  // It's the perfect place to perform one-time setup, like initiating the login check.
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  /// Checks the current user's authentication status and navigates accordingly.
  void _checkLogin() async {
    // Retrieve the current user from Firebase Authentication.
    // If the user is logged in, this will be a User object; otherwise, it will be null.
    final user = FirebaseAuth.instance.currentUser;

    // Wait for a short duration to ensure the splash screen is visible for a minimum amount of time.
    // This improves the user experience by preventing a jarringly fast transition.
    await Future.delayed(const Duration(seconds: 1));

    // Create an instance of the AuthService to be passed to the home screen if the user is logged in.
    final authService = AuthService();

    // Check if the user object is null. This is the core of the authentication check.
    if (user != null) {
      // If the user is not null, they are logged in. Navigate to the home screen.
      // We use pushReplacementNamed to prevent the user from navigating back to the splash screen.
      Navigator.pushReplacementNamed(
        context,
        '/home',
        // Pass the user and authService to the home screen using the type-safe HomeArguments class.
        arguments: HomeArguments(user, authService),
      );
    } else {
      // If the user is null, they are not logged in. Navigate to the login screen.
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // The build method describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure of the visual interface.
    return Scaffold(
      // Center widget aligns its child to the center of the screen.
      body: Center(
        // Column arranges its children in a vertical array.
        child: Column(
          // Align the children to the center of the main axis (the vertical axis for a Column).
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display an icon that represents the app's logo.
            Icon(
              Icons.account_balance_wallet,
              size: 90, // A large, prominent size.
              color: Colors.blue[200], // A soft, pastel blue color.
            ),
            // A SizedBox creates a fixed-size box, used here as a vertical spacer.
            const SizedBox(height: 24),
            // Display the app's name.
            Text(
              'SmartSpends',
              style: TextStyle(
                fontSize: 32, // A large, readable font size.
                fontWeight: FontWeight.bold, // Make the text bold.
                color: Colors.grey[600], // A dark grey color for good contrast.
                letterSpacing: 1.0, // Add some space between letters for a more refined look.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
