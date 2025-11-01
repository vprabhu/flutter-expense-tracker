import 'package:expense_tracker/screens/expenses_list_screen.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/widgets/bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A stateful widget that manages the main navigation of the app using a bottom
/// navigation bar. It uses an `IndexedStack` to preserve the state of each screen
/// as the user navigates between them.
class NavBar extends StatefulWidget {
  // The currently authenticated Firebase user.
  final User user;
  // An instance of the AuthService, used for handling sign-out operations.
  final AuthService authService;

  // The constructor for the NavBar widget.
  const NavBar({super.key, required this.user, required this.authService});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  // The index of the currently selected tab in the bottom navigation bar.
  int _currentIndex = 0;

  // A list of the widgets to be displayed as the main content for each tab.
  late final List<Widget> _screens;

  // Called once when the widget is inserted into the widget tree.
  @override
  void initState() {
    super.initState();
    // Initialize the list of screens.
    _screens = [
      // The main expenses screen, which shows a summary and recent expenses.
      const ExpensesScreen(),
      // A screen that displays a list of all expenses.
      const ExpensesListScreen(),
      // The user's profile screen, which allows them to sign out.
      ProfileScreen(authService: widget.authService),
    ];
  }

  /// A callback function that is called when a new destination is selected in the
  /// bottom navigation bar. It updates the `_currentIndex` to switch to the
  /// corresponding screen.
  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack is a widget that shows a single child from a list of children.
      // It's useful for bottom navigation because it preserves the state of the
      // other screens when you switch between them.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // The custom bottom navigation bar for the app.
      bottomNavigationBar: AppBottomBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
