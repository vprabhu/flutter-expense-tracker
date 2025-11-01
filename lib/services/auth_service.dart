import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as dev; // For log(), if not already imported

/// A service class that manages authentication logic for the app,
/// abstracting all Google Sign-In and Firebase Auth integration.
///
/// This class is designed to be easily testable, scalable, and plug-and-play
/// with any UI. It encapsulates all authentication-related logic, so the UI
/// only needs to call methods like `signInWithGoogleAndStore()` and `signOut()`.

class AuthService {

  // An instance of FirebaseAuth, the entry point of the Firebase Authentication SDK.
  // It's used to interact with the Firebase Auth backend.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Signs in with Google and returns the user.
  /// This method orchestrates the entire sign-in flow.
  ///
  /// It first calls `signInWithGoogle` to get the user from the Google provider.
  /// If the sign-in is successful and a user is returned, it simply returns that user.
  /// If the Google sign-in process returns null (e.g., the user cancelled),
  /// it waits for the next authentication state change from Firebase to ensure
  /// the app's auth state is correctly updated.
  ///
  /// Returns the Firebase [User] if sign-in is successful, otherwise returns null or completes a future with the user.
  Future<User?> signInWithGoogleAndStore() async {
    // This method previously stored user data in Firestore, and its name is kept for compatibility.
    // It now only handles the authentication flow.
    final user = await signInWithGoogle();
    if (user != null) {
      // If the sign-in was successful, the user object is ready.
      return user;
    }

    // If `signInWithGoogle` returned null (e.g., user cancelled the dialog),
    // this line waits for the next authentication state change from Firebase.
    // It's a fallback to ensure that if an auth change happens for any other reason,
    // the app will react to it. It listens to the stream of auth changes and returns
    // the first user object that is not null.
    return _auth.authStateChanges().firstWhere((u) => u != null);
  }

  /// Handles the Google Sign-In process and authenticates with Firebase.
  ///
  /// This method performs the following steps:
  /// 1. Triggers the native Google Sign-In UI.
  /// 2. If the user selects an account, it obtains the authentication tokens.
  /// 3. It creates a Firebase credential using the tokens from Google.
  /// 4. It signs the user into Firebase with that credential.
  ///
  /// Returns the authenticated Firebase [User] on success, or null if the user cancels.
  Future<User?> signInWithGoogle() async {
    dev.log("signInWithGoogle called");

    // 1. Trigger the Google Sign-In UI flow.
    // This opens the standard Google account selection dialog.
    final googleUser = await GoogleSignIn().signIn();

    // If `googleUser` is null, it means the user cancelled the sign-in process.
    if (googleUser == null) {
      dev.log("Google Sign-In cancelled by user.");
      return null; // User aborted/cancelled
    }

    // 2. Obtain the authentication tokens from the signed-in Google account.
    // The `authentication` property returns a future that completes with an
    // object containing the `accessToken` and `idToken`.
    final googleAuth = await googleUser.authentication;

    // 3. Build a Firebase credential using the Google tokens.
    // This credential object is what Firebase uses to verify the user's identity.
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in to FirebaseAuth with the Google credential.
    // This exchanges the credential for a Firebase session.
    final userCredential = await _auth.signInWithCredential(credential);

    dev.log("signInWithGoogle completed: ${userCredential.user}");
    // Return the signed-in Firebase user.
    return userCredential.user;
  }
  /// Signs out from both Firebase authentication and the Google provider.
  ///
  /// Completes when fully signed out, ensuring fresh login on next attempt.
  Future<void> signOut() async {
    // Signs out from Firebase, clearing the user's session.
    await _auth.signOut();
    // Disconnects the Google account to ensure the user is prompted to sign in again.
    await GoogleSignIn().signOut(); 
    dev.log("signOut called: User signed out from Firebase and Google.");
  }
}
