import 'package:flutter/material.dart';

/// A custom bottom navigation bar for the application.
///
/// This widget uses the [NavigationBar] from Material 3 to provide a modern
/// and customizable bottom navigation experience. It takes the current index and
/// a callback function to handle destination selection.
class AppBottomBar extends StatelessWidget {
  /// The index of the currently selected destination.
  final int currentIndex;

  /// A callback function that is called when a new destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Creates an instance of the [AppBottomBar] widget.
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // The NavigationBar widget is a Material 3 component that provides a
    // bottom navigation bar with a set of destinations.
    return NavigationBar(
      // The index of the currently selected destination.
      selectedIndex: currentIndex,
      // The callback function that is called when a new destination is selected.
      onDestinationSelected: onDestinationSelected,
      // The list of destinations to be displayed in the navigation bar.
      destinations: const [
        // The "Home" destination.
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        // The "Stats" destination.
        NavigationDestination(icon: Icon(Icons.insert_chart), label: 'Stats'),
        // The "Profile" destination.
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
