import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A service class that manages authentication logic for the app,
/// abstracting all Google Sign-In and Firebase Auth integration.
///
/// Easily testable, scalable, and plug-and-play with any UI.

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  /// Signs in with Google and stores in Firestore
  /// Signs in the user with Google authentication and returns the Firebase [User].
  ///
  /// If the user cancels the sign-in flow, null is returned.
  /// Throws exceptions if network or provider fails.
  /// Note: Firestore storage is now fire-and-forget to avoid delaying auth completion.
  Future<User?> signInWithGoogleAndStore() async {
    final user = await signInWithGoogle();
    if (user != null) {
      // Fire-and-forget: Store user data in background without awaiting.
      // This avoids delays on first-time writes while ensuring idempotency.
      _storeUserInFirestoreAsync(user);
      return user;
    }

    // If user is null, wait for Firebase to emit the auth state
    return _auth.authStateChanges().firstWhere((u) => u != null);
  }

  /// Async version of _storeUserInFirestore for fire-and-forget usage.
  Future<void> _storeUserInFirestoreAsync(User user) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await userRef.get();
      if (!doc.exists) {
        await userRef.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Optional: Log error (e.g., via Firebase Crashlytics) but don't fail auth.
      log('Failed to store user in Firestore: $e');
    }
  }

  // Keep the original for other uses if needed (e.g., awaited elsewhere).
  Future<void> _storeUserInFirestore(User user) async {
    await _storeUserInFirestoreAsync(user); // Delegate to async version.
  }


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
