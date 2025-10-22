import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../widgets/pie_chart.dart';
import '../widgets/spendingBreakdown.dart';
import 'add_expenses_screen.dart';
import '../widgets/recent_list.dart';
import 'expense_details_screen.dart';
import 'filter_screen.dart';
import 'package:intl/intl.dart';

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
      date: DateTime(2025, 10, 1),
      icon: Icons.store,
      color: Colors.blue[300],
      id: '',
      note:
          "Full form with merchant, amount, category, date, note, receipt upload",
    ),
    Expense(
      title: 'Gas Station',
      category: 'Gas',
      amount: 45.00,
      date: DateTime(2025, 10, 2),
      icon: Icons.local_gas_station,
      color: Colors.blue[400],
    ),
    Expense(
      title: 'Cinema',
      category: 'Movie',
      amount: 20.00,
      date: DateTime(2025, 10, 22),
      icon: Icons.movie,
      color: Colors.blue[200],
    ),
    Expense(
      title: 'Utility Company',
      category: 'Electricity',
      amount: 150.00,
      date: DateTime(2025, 10, 5),
      icon: Icons.bolt,
      color: Colors.blue[100],
    ),
    Expense(
      title: 'Fashion Store',
      category: 'Clothing',
      amount: 100.00,
      date: DateTime(2025, 10, 9),
      icon: Icons.shopping_bag,
      color: Colors.blue[500],
    ),
  ];

  // Total spent: Hardcoded as per design
  // final double totalSpent = 1250.00;
  DateTimeRange? _filterRange; // Current filter range (null for all)

  // Computed: Total spent from filtered expenses
  double get totalSpent {
    final filtered = _getFilteredExpenses();
    return filtered.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  // Pie chart data: Categories with amounts and colors matching design shades
  // Food (blue), Transport (darker blue), Entertainment (light blue), Utilities (lighter blue)
  final List<PieSegment> pieData = [
    PieSegment(label: 'Food', amount: 450.0, color: Colors.blue[600]!),
    PieSegment(label: 'Transport', amount: 300.0, color: Colors.blue[700]!),
    PieSegment(label: 'Entertainment', amount: 200.0, color: Colors.blue[300]!),
    PieSegment(label: 'Utilities', amount: 300.0, color: Colors.blue[100]!),
  ];

  // Helper: Get filtered expenses based on _filterRange
  List<Expense> _getFilteredExpenses() {
    if (_filterRange == null) return _recentExpenses;
    return _recentExpenses.where((expense) {
      // Include expenses within the date range (inclusive, with day buffer for edge cases)
      final date = expense.date;
      if (date == null) return false;
      return date.isAfter(
            _filterRange!.start.subtract(const Duration(days: 1)),
          ) &&
          date.isBefore(_filterRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  // Functionality: Navigate to AddExpenseScreen on + tap
  void _navigateToAddExpense() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const AddExpenseScreen()))
        .then((result) {
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

  // Functionality: Navigate to FilterExpensesScreen and update filter on return
  void _navigateToFilter() async {
    final range = await Navigator.of(context).push<DateTimeRange?>(
      MaterialPageRoute(
        builder: (context) => FilterExpensesScreen(initialRange: _filterRange),
      ),
    );
    if (range != null) {
      setState(() {
        _filterRange = range;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Filter applied: ${DateFormat('MMM yyyy').format(range.start)}',
          ),
        ),
      );
    }
  }

  // Navigate to ExpenseDetailsScreen for editing/viewing
  void _onExpenseTap(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExpenseDetailsScreen(
          expense: _recentExpenses[index],
          index: index,
          onUpdate: (idx, updated) {
            setState(() {
              _recentExpenses[idx] = updated;
            });
          },
        ),
      ),
    );
  }

  // Functionality: Handle tap on recent expense (e.g., show dialog with details)
  /*
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
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expenses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, color: Colors.white),
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
            Row(
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.black, size: 26),
                  onPressed: _navigateToFilter,
                ),
                // Icon(Icons.filter_alt, color: Colors.blue,size: 32,),
                SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentExpenses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final expense = _recentExpenses[index];
                return buildExpenseCard(expense, () => _onExpenseTap(0));
                // expense, () => _onExpenseTap(expense));
              },
            ),
          ],
        ),
      ),
    );
  }
}
