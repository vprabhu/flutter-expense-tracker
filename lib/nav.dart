import 'package:expense_tracker/screens/filter_screen.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/profile_screen.dart';
import 'package:expense_tracker/screens/summary_screen.dart';
import 'package:expense_tracker/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';

// MainScreen: Handles bottom navigation with IndexedStack for efficient screen switching
// This structure preserves state across tabs and handles navigation between Home, Stats (Expenses), and Profile
class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 1; // Start on Stats/Expenses (index 1, as per design focus)

  // List of screens for IndexedStack: 0=Home, 1=Stats/Expenses, 2=Profile
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens (Home and Profile are placeholders; expand as needed)
    _screens = [
      const ExpensesScreen(), // Stats/Expenses screen (from previous code)
      // const SummaryScreen(), // Placeholder Home screen
      const FilterExpensesScreen(), // Placeholder Home screen
      const ProfileScreen(), // Placeholder Profile screen

    ];
  }

  // Functionality: Handle bottom nav selection - update index and rebuild
  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, // Switches between screens without rebuilding
      ),
      bottomNavigationBar: AppBottomBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected, // Pass callback for handling
      ),
    );
  }
}
