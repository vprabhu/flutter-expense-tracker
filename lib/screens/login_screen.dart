import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:flutter/material.dart';

/// The login/start screen for the app,
/// focused on modern, minimal onboarding UX.
///
/// Only offers Google Sign-In, visibly anchored to the bottom for reachability.
/// You would set this as your `home:` in `MaterialApp`.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService = AuthService(); // Dependency-injected for testability and reuse
  bool isSigningIn = false; // Local state for progress feedback

  /// Callback for the Google Sign-In button.
  /// Triggers the AuthService logic and, on success, navigates to HomeScreen.
  Future<void> _handleSignIn() async {
    setState(() => isSigningIn = true);
    final user = await _authService.signInWithGoogle();
    setState(() => isSigningIn = false);

    if (user != null) {
      // Navigate to home; prevents going "back" to login.
      // Navigator.pushReplacementNamed(context, '/home');
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'user': user,               // Your logged-in Firebase user
          'authService': _authService, // Your AuthService instance
        },
      );
    } else {
      // Optionally: show a cancel/toast or just silently stay
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Stack allows easy placement of button at the bottom.
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                // Google's brand color/icon should be inserted here in production!
                icon: Icon(Icons.login, color: Colors.red), // Use image asset for final polish
                label: isSigningIn
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100], // On-brand subtle blue
                  foregroundColor: Colors.blue[800],
                  textStyle: const TextStyle(fontSize: 19),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: isSigningIn ? null : _handleSignIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

