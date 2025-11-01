import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/notifiers/add_expense_notifier.dart';
import '../utils/Constants.dart';
import '../widgets/expense_card.dart';
import 'add_expenses_screen.dart';
import 'expense_details_screen.dart';

/// The main screen for viewing, filtering, and sorting expenses.
///
/// This screen displays a list of expenses with tabs for filtering by category.
/// It also provides options for sorting, searching, and filtering by date.
class ExpensesListScreen extends ConsumerStatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  // The currently selected date range for filtering.
  DateTimeRange? _filterRange;
  // The currently selected category for filtering.
  String _selectedCategory = 'All';
  // The current search query.
  String _searchQuery = '';
  // The current sort type.
  SortType _sortType = SortType.dateDesc;

  /// Navigates to the screen for adding a new expense.
  void _navigateToAdd() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
  }

  /// Shows a date range picker to allow the user to filter expenses by date.
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
          content: Text('Filter: ${DateFormat.yMMMd().format(range.start)} - ${DateFormat.yMMMd().format(range.end)}'),
        ),
      );
    }
  }

  /// Shows a dialog to allow the user to choose a sort order.
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
                  title: Text({
                    SortType.dateDesc: 'Date (newest)',
                    SortType.dateAsc: 'Date (oldest)',
                    SortType.amountDesc: 'Amount (high)',
                    SortType.amountAsc: 'Amount (low)',
                  }[e]!),
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

  /// Deletes an expense after showing a confirmation dialog.
  Future<void> _deleteExpense(Expense exp) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete?'),
        content: Text('Delete "${exp.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    await ref.read(expensesNotifierProvider.notifier).deleteExpense(exp.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted')));
  }

  /// Filters and sorts the list of expenses based on the current filters and sort order.
  List<Expense> _filterAndSort(List<Expense> source) {
    var list = source.where((e) {
      final inDateRange = _filterRange == null ||
          (e.date.isAfter(_filterRange!.start) && e.date.isBefore(_filterRange!.end));
      final inCategory = _selectedCategory == 'All' || e.category == _selectedCategory;
      final inSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      return inDateRange && inCategory && inSearch;
    }).toList();

    // Sort the list based on the selected sort type.
    list.sort((a, b) {
      switch (_sortType) {
        case SortType.dateDesc:
          return b.date.compareTo(a.date);
        case SortType.dateAsc:
          return a.date.compareTo(b.date);
        case SortType.amountDesc:
          return b.amount.compareTo(a.amount);
        case SortType.amountAsc:
          return a.amount.compareTo(b.amount);
      }
    });

    return list;
  }

  /// A callback function that is called when a category tab is selected.
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  /// Navigates to the expense details screen when an expense is tapped.
  void _onExpenseTap(Expense expense) {
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
          // The category filter tabs.
          SizedBox(
            height: 50,
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
          // The list of expenses.
          Expanded(
            child: asyncExpenses.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Center(child: Text('Error: $err')),
              data: (raw) {
                final filtered = _filterAndSort(raw);
                if (filtered.isEmpty) return const Center(child: Text('No expenses'));
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final exp = filtered[i];
                    return buildExpenseCard(exp, () => _onExpenseTap(exp));
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
