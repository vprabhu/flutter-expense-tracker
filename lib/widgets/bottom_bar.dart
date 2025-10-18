import 'package:flutter/material.dart';

/* ----------------------------------------------------------
   Bottom navigation – Home / Stats / Profile
   ---------------------------------------------------------- */
// AppBottomBar: Updated to accept currentIndex and onDestinationSelected for proper state management
// Structure idea: Use NavigationBar for modern Material 3 look; callback drives index changes in parent
class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.insert_chart), label: 'Stats'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}