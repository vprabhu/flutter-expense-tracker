import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../widgets/pie_chart.dart';
import '../widgets/spendingBreakdown.dart';
import 'add_expenses_screen.dart';
import '../widgets/recent_list.dart';

// ExpensesScreen: The main screen displaying expenses breakdown and recent expenses
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {

  // Sample data for recent expenses: List of expense items
  // final List<Expense> _recentExpenses = dummyExpenses;
  final List<Expense> _recentExpenses = [
    Expense(
        title: 'Fresh Foods Market',
        category: 'Grocery',
        amount: 75.00,
        icon: Icons.store,
        color: Colors.blue[300],
        id: ''
    ),
    Expense(
      title: 'Gas Station',
      category: 'Gas',
      amount: 45.00,
      icon: Icons.local_gas_station,
      color: Colors.blue[400],
    ),
    Expense(
      title: 'Cinema',
      category: 'Movie',
      amount: 20.00,
      icon: Icons.movie,
      color: Colors.blue[200],
    ),
    Expense(
      title: 'Utility Company',
      category: 'Electricity',
      amount: 150.00,
      icon: Icons.bolt,
      color: Colors.blue[100],
    ),
    Expense(
      title: 'Fashion Store',
      category: 'Clothing',
      amount: 100.00,
      icon: Icons.shopping_bag,
      color: Colors.blue[500],
    ),
  ];

  // Total spent: Hardcoded as per design
  final double totalSpent = 1250.00;

  // Pie chart data: Categories with amounts and colors matching design shades
  // Food (blue), Transport (darker blue), Entertainment (light blue), Utilities (lighter blue)
  final List<PieSegment> pieData = [
    PieSegment(label: 'Food', amount: 450.0, color: Colors.blue[600]!),
    PieSegment(label: 'Transport', amount: 300.0, color: Colors.blue[700]!),
    PieSegment(label: 'Entertainment', amount: 200.0, color: Colors.blue[300]!),
    PieSegment(label: 'Utilities', amount: 300.0, color: Colors.blue[100]!),
  ];

// Functionality: Navigate to AddExpenseScreen on + tap
  void _navigateToAddExpense() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    ).then((result) {
      // Optional: Handle result from AddExpense (e.g., refresh list if new expense added)
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
        // Trigger setState to refresh if needed
        setState(() {});
      }
    });
  }

  // Functionality: Handle tap on recent expense (e.g., show dialog with details)
  void _onExpenseTap(Expense expense) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(expense.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${expense.category}'),
                Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
                Text('Date: Oct 18, 2025'), // Placeholder date
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expenses', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),),
          centerTitle: true,
        ),
        floatingActionButton: IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: _navigateToAddExpense,
            color: Colors.red
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Spending Breakdown Section
              const Text(
                'Spending Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              buildSpendingBreakdown(totalSpent, pieData),
              const SizedBox(height: 24),
              // Recent Expenses Section
              const Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentExpenses.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final expense = _recentExpenses[index];
                  return buildExpenseCard(
                      expense, () => _onExpenseTap(expense));
                },
              ),
            ],
          ),
        )
    );
  }
}
