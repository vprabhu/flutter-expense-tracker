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


