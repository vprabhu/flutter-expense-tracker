import 'dart:developer';

import 'package:expense_tracker/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Main entry point for the Expenses app
void main() {
  runApp(const ExpensesApp());
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(SmartSpendsApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Login Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignInScreen(),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  User? user;
  bool isSigningIn = false;

  Future<void> signInWithGoogle() async {
    log("Entered signInWithGoogle");
    setState(() => isSigningIn = true);

    final googleUser = await GoogleSignIn().signIn();
    // final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
    // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    log("googleUser -> $googleUser");
    if (googleUser == null) {
      setState(() => isSigningIn = false);
      return; // user canceled
    }
    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    setState(() {
      user = userCredential.user;
      log("googleUser -> $user");
      isSigningIn = false;
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    setState(() {
      user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Center(
        child: user == null
            ? isSigningIn
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                      onPressed: signInWithGoogle,
                    )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (user!.photoURL != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL!),
                      radius: 40,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Hello, ${user!.displayName ?? 'User'}!',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(user!.email ?? ''),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                    onPressed: signOut,
                  ),
                ],
              ),
      ),
    );
  }
}
