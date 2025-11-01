import 'package:expense_tracker/root_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main entry point of the application.
void main() async {
  // Ensure that the Flutter binding is initialized before calling any Flutter APIs.
  // This is required for platform channel communication to happen before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase. This must be done before any Firebase services are used.
  // The `await` keyword ensures that the app doesn't start until Firebase is ready.
  await Firebase.initializeApp();

  // Run the application.
  // The ProviderScope widget is from the flutter_riverpod package. It stores the
  // state of all the providers you create. For Riverpod to work, you need to
  // wrap your entire application in a ProviderScope.
  runApp(const ProviderScope(
    // The root widget of the application.
    child: SmartSpendsApp(),
  ));
}
