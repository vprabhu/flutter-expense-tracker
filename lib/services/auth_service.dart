import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service class that manages authentication logic for the app,
/// abstracting all Google Sign-In and Firebase Auth integration.
///
/// Easily testable, scalable, and plug-and-play with any UI.
class AuthService {
  /// The singleton FirebaseAuth instance used for all FirebaseAuth operations.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in the user with Google authentication and returns the Firebase [User].
  ///
  /// If the user cancels the sign-in flow, null is returned.
  /// Throws exceptions if network or provider fails.
  Future<User?> signInWithGoogle() async {
    log("signInWithGoogle called");

    // Trigger the Google Sign-In UI.
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // User aborted/cancelled

    // Obtain the authentication tokens from the signed-in Google account.
    final googleAuth = await googleUser.authentication;

    // Build a credential for Firebase authentication using Google tokens.
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to FirebaseAuth with the Google credential.
    final userCredential = await _auth.signInWithCredential(credential);

    log("signInWithGoogle called ${userCredential.user}");
    // Return the signed-in Firebase user.
    return userCredential.user;
  }

  /// Signs out from both Firebase authentication and the Google provider.
  ///
  /// Completes when fully signed out, ensuring fresh login on next attempt.
  Future<void> signOut() async {
    await _auth.signOut(); // Signs out from Firebase
    await GoogleSignIn().signOut(); // Disconnects Google account
    log("signOut called");
  }
}
