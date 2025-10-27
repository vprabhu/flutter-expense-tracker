import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../model/notifiers/add_expense_notifier.dart';
import '../widgets/expense_card.dart';
import '../widgets/pie_chart.dart';
import '../widgets/spendingBreakdown.dart';
import 'add_expenses_screen.dart';
import 'expense_details_screen.dart';
import 'filter_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HomeScreen displays user financial summary, recent expense list, and a custom logout flow.
///
/// User data is passed in from login, so every widget can show the actual displayName, email, photoURL, etc.
/// This is fully scalable: replace dummy data with real backend or Firestore later.
///

// ExpensesScreen: The main screen displaying expenses breakdown and recent expenses
/* ===================================================================
   1.  SCREEN – now ConsumerStateful so we can watch Firestore
   =================================================================== */
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  /* ------------------------------------------------------------------
     Local UI state
     ------------------------------------------------------------------ */
  DateTimeRange? _filterRange; // date-range filter

  /* ------------------------------------------------------------------
     Helpers that work on LIVE Firestore data
     ------------------------------------------------------------------ */
  List<Expense> _filtered(List<Expense> source) {
    if (_filterRange == null) return source;
    final start = _filterRange!.start.subtract(const Duration(days: 1));
    final end = _filterRange!.end.add(const Duration(days: 1));
    return source
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList();
  }

  double _totalSpent(List<Expense> list) =>
      list.fold(0.0, (sum, e) => sum + e.amount);

  List<PieSegment> _pieSegments(List<Expense> list) {
    final map = <String, double>{};
    for (final e in list) {
      map.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
    }
    if (map.isEmpty) return [];
    final colours = [
      Colors.blue[600]!,
      Colors.blue[700]!,
      Colors.blue[300]!,
      Colors.blue[100]!,
    ];
    int i = 0;
    return map.entries
        .map(
          (e) => PieSegment(
            label: e.key,
            amount: e.value,
            color: colours[i++ % colours.length],
          ),
        )
        .toList();
  }

  void _navigateToAdd() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
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
  Future<void> _filterByDate() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _filterRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (range != null) {
      setState(() => _filterRange = range);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Filter: ${DateFormat.yMMMd().format(range.start)} - ${DateFormat.yMMMd().format(range.end)}',
          ),
        ),
      );
    }
  }

  void _onExpenseTap(Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseDetailsScreen(expense: expense)),
    );
  }

  /* ===================================================================
     2.  BUILD – identical layout, real data
     =================================================================== */
  @override
  Widget build(BuildContext context) {
    /* watch the async list from Firestore */
    final asyncExpenses = ref.watch(expensesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: asyncExpenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Error: $err')),
        data: (rawList) {
          final recent = _filtered(rawList);
          final total = _totalSpent(recent);
          final pieData = _pieSegments(recent);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* ---------------  Spending Breakdown  --------------- */
                const Text(
                  'Spending Breakdown',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                buildSpendingBreakdown(total, pieData),
                const SizedBox(height: 24),

                /* ---------------  Recent Expenses  --------------- */
                Row(
                  children: [
                    const Text(
                      'Recent Expenses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Colors.black,
                        size: 26,
                      ),
                      onPressed: _navigateToFilter,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (recent.isEmpty)
                  const Center(child: Text('No expenses for this period'))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => buildExpenseCard(
                      recent[i],
                      () => _onExpenseTap(recent[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ExpensesScreen1 extends StatefulWidget {
  const ExpensesScreen1({super.key});

  @override
  State<ExpensesScreen1> createState() => _ExpensesScreenState1();
}

class _ExpensesScreenState1 extends State<ExpensesScreen1> {
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
        builder: (context) =>
            ExpenseDetailsScreen(expense: _recentExpenses[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expenses',
          style: const TextStyle(
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
