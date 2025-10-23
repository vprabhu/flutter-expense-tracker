import 'package:expense_tracker/services/auth_service.dart';
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
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// HomeScreen displays user financial summary, recent expense list, and a custom logout flow.
///
/// User data is passed in from login, so every widget can show the actual displayName, email, photoURL, etc.
/// This is fully scalable: replace dummy data with real backend or Firestore later.
///
class HomeScreen extends StatelessWidget {
  final User user; // The authenticated user
  final AuthService authService; // For seamless logout

  const HomeScreen({
    super.key,
    required this.user,
    required this.authService,
  });

  // Sample category data for spending breakdown.
  static const categories = [
    {'name': 'Food', 'color': Color(0xFF247CFF)},
    {'name': 'Transport', 'color': Color(0xFF61AAFF)},
    {'name': 'Entertainment', 'color': Color(0xFF97C9FF)},
    {'name': 'Utilities', 'color': Color(0xFFC6E4FF)}
  ];

  // Sample expense list. Replace with model/backend fetch later.
  static const expenses = [
    {'title': 'Fresh Foods Market', 'subtitle': 'Grocery', 'amount': -75, 'icon': Icons.shopping_bag},
    {'title': 'Gas Station', 'subtitle': 'Gas', 'amount': -45, 'icon': Icons.local_gas_station},
    {'title': 'Cinema', 'subtitle': 'Movie', 'amount': -20, 'icon': Icons.tv},
    {'title': 'Utility Company', 'subtitle': 'Electricity', 'amount': -150, 'icon': Icons.flash_on},
    {'title': 'Fashion Store', 'subtitle': 'Clothing', 'amount': -100, 'icon': Icons.shopping_cart},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Displays user's name & photo
        title: Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          CircleAvatar(
            backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null ? Icon(Icons.person) : null,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: () async {
              await authService.signOut();
              // Return to login screen. Replace with routing logic as needed.
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spending Breakdown with a chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text('Spending Breakdown',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Row(
                children: [
                  // Dummy chart (replace with real chart widget for full effect)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.8, // percentage spent, fake
                          strokeWidth: 10,
                          valueColor: AlwaysStoppedAnimation(categories[0]['color'] as Color),
                          backgroundColor: categories[2]['color'] as Color,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Total Spent", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("\$1,250", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categories.map((c) => Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: c['color'] as Color, shape: BoxShape.circle),
                            ),
                            SizedBox(width: 8),
                            Text(c['name'] as String),
                          ],
                        )).toList(),
                      )
                  )
                ],
              ),
            ),
          ),

          // Recent Expenses List
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 0, 10),
            child: Text('Recent Expenses',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: expenses.length,
              itemBuilder: (_, i) {
                final e = expenses[i];
                return Card(
                  margin: EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 21,
                      backgroundColor: Colors.blue[50],
                      child: Icon(e['icon'] as IconData, color: Colors.blue[700]),
                    ),
                    title: Text(e['title'] as String,
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(e['subtitle'] as String,
                        style: TextStyle(color: Colors.blueGrey)),
                    trailing: Text(
                      "\$${e['amount']}.00",
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation Bar (fake, for showcase. Replace with real PageView/BottomNavBar)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(icon: Icons.home, label: "Home", selected: true),
                _BottomNavItem(icon: Icons.bar_chart, label: "Summary"),
                _BottomNavItem(icon: Icons.person, label: "Profile"),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// Simple widget for bottom navigation bar icon, not interactive, but beautiful for mockups.
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const _BottomNavItem({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: selected ? Colors.blue[700] : Colors.blueGrey[400]),
        SizedBox(height: 5),
        Text(label,
            style: TextStyle(
              color: selected ? Colors.blue[700] : Colors.blueGrey[400],
              fontWeight: selected ? FontWeight.bold : FontWeight.w400,
              fontSize: 15,
            )
        ),
      ],
    );
  }
}
