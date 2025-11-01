import 'package:flutter/material.dart';

/// A placeholder screen for the home tab.
///
/// This screen is intended to be expanded with a dashboard that provides a
/// summary of the user's expenses.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Summary Screen',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
