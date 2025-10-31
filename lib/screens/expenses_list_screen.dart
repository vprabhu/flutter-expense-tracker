import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/notifiers/add_expense_notifier.dart';
import '../utils/Constants.dart';
import '../utils/formatters.dart';
import '../widgets/expense_card.dart';
import '../widgets/search_expenses.dart';
import 'add_expenses_screen.dart';
import 'expense_details_screen.dart';
import 'filter_screen.dart';

// ExpensesScreen: Main screen for viewing expenses with category tabs, search, sort, and date filter integration
// Structure: Displays filtered/sorted/searched list; pie chart removed for this tabbed list focus; navigates from filter apply
class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  DateTimeRange? _filterRange; // Date filter from FilterScreen
  String _selectedCategory = 'All'; // Selected tab category
  String _searchQuery = ''; // Current search query
  SortType _sortType =
      SortType.dateDesc; // Current sort (date descending by default)

  /* ----------  navigation helpers  ---------- */
  void _navigateToAdd() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
    /* When we save, notifier will emit new list → UI auto updates */
  }

  Future<void> _navigateToFilter() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _filterRange,
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortType.values
              .map(
                (e) => RadioListTile<SortType>(
                  title: Text(
                    {
                      SortType.dateDesc: 'Date (newest)',
                      SortType.dateAsc: 'Date (oldest)',
                      SortType.amountDesc: 'Amount (high)',
                      SortType.amountAsc: 'Amount (low)',
                    }[e]!,
                  ),
                  value: e,
                  groupValue: _sortType,
                  onChanged: (v) {
                    setState(() => _sortType = v!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  /* ----------  delete with confirmation  ---------- */
  Future<void> _deleteExpense(Expense exp) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: Text('Delete "${exp.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(expensesNotifierProvider.notifier).deleteExpense(exp.id!);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Deleted')));
  }

  /* ----------  filtering & sorting  ---------- */
  List<Expense> _filterAndSort(List<Expense> source) {
    var list = source.where((e) {
      if (_filterRange != null) {
        final start = _filterRange!.start;
        final end = _filterRange!.end;
        if (e.date == null || e.date!.isBefore(start) || e.date!.isAfter(end)) {
          return false;
        }
      }
      if (_selectedCategory != 'All' && e.category != _selectedCategory)
        return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return e.title.toLowerCase().contains(q) ||
            (e.note?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();

    switch (_sortType) {
      //Option 1: Put null dates at the bottom
      case SortType.dateDesc:
        list.sort((a, b) {
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });
        break;

      case SortType.dateAsc:
        list.sort((a, b) {
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return a.date!.compareTo(b.date!);
        });
        break;
      case SortType.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortType.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  // Functionality: Handle category tab selection
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // Functionality: Navigate to details for editing
  void _onExpenseTap(Expense expense) {
    /*  We no longer need “index” or callbacks – the detail screen
      will read & write straight to Firestore via Riverpod  */
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExpenseDetailsScreen(expense: expense)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncExpenses = ref.watch(expensesNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onPressed: _navigateToFilter,
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.blue),
            onPressed: _showSortDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: _navigateToAdd,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Tabs/Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Constants.tabCategories.length,
              itemBuilder: (context, index) {
                final category = Constants.tabCategories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (_) => _onCategorySelected(category),
                    selectedColor: Colors.blue[50],
                    backgroundColor: Colors.grey[100],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: asyncExpenses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Center(child: Text('Error: $err')),
              data: (raw) {
                final filtered = _filterAndSort(raw);
                if (filtered.isEmpty)
                  return const Center(child: Text('No expenses'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final exp = filtered[i];
                    return  buildExpenseCard(exp, () => _onExpenseTap(exp));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
