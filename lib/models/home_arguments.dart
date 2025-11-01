import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/services/auth_service.dart';

/// A class to encapsulate the arguments passed to the home screen.
///
/// Using a dedicated class for navigation arguments provides type safety and
/// clarity, making the code easier to read and maintain. It prevents common
/// errors that can occur when passing arguments as a `Map`.
class HomeArguments {
  /// The currently authenticated Firebase user.
  final User user;

  /// An instance of the [AuthService], used for handling sign-out operations.
  final AuthService authService;

  /// Creates an instance of the [HomeArguments] class.
  HomeArguments(this.user, this.authService);
}
