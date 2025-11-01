import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/services/auth_service.dart';

class HomeArguments {
  final User user;
  final AuthService authService;

  HomeArguments(this.user, this.authService);
}
