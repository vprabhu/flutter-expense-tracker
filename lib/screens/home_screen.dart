import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Welcome to BudgetWise!', style: TextStyle(fontSize: 26))),
    );
  }
}
