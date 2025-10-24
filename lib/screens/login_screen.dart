import 'dart:developer';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthService _authService =
      AuthService(); // Dependency-injected for testability and reuse
  bool isSigningIn = false; // Local state for progress feedback

  Future<void> _onSignInPressed() async {
    setState(() => isSigningIn = true);
    try {
      final user = await _authService.signInWithGoogleAndStore();
      setState(() => isSigningIn = false);
      if (user != null && mounted) {
        // Direct navigation—no post-frame deferral needed.
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {'user': user, 'authService': _authService},
        );
      } else if (mounted) {
        // Handle null user (e.g., cancelled sign-in)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign-in was cancelled.')));
      }
    } catch (e) {
      setState(() => isSigningIn = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
        );
      }
      log('Sign-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(32.0).copyWith(bottom: 150),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login, color: Colors.red),
                label: isSigningIn
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[100],
                  foregroundColor: Colors.blue[800],
                  textStyle: const TextStyle(fontSize: 19),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                onPressed: () {
                  _onSignInPressed();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
