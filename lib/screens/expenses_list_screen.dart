import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/search_expenses.dart';
import 'add_expenses_screen.dart';
import 'expense_details_screen.dart';
import 'filter_screen.dart';

// Enum for sorting options
enum SortType { dateDesc, dateAsc, amountDesc, amountAsc }

// ExpensesScreen: Main screen for viewing expenses with category tabs, search, sort, and date filter integration
// Structure: Displays filtered/sorted/searched list; pie chart removed for this tabbed list focus; navigates from filter apply
class ExpensesListScreen extends StatefulWidget {
  const ExpensesListScreen({super.key});

  @override
  State<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends State<ExpensesListScreen> {
  // Sample data: Updated with dates relative to Oct 19, 2025; categories mapped to tabs (e.g., Groceries -> Food)
  final List<Expense> _allExpenses = [
    Expense(
      title: 'Supermarket',
      category: 'Food',
      // Mapped from Groceries
      amount: 50.00,
      icon: Icons.shopping_cart,
      color: Colors.blue[300],
      date: DateTime(2025, 10, 19),
      // Today
      note: 'Groceries',
      // imagePath: null,
    ),
    Expense(
      title: 'Bus Ticket',
      category: 'Travel',
      // Transportation
      amount: 25.00,
      icon: Icons.directions_bus,
      color: Colors.blue[400],
      date: DateTime(2025, 10, 18),
      // Yesterday
      note: 'Transportation',
      // imagePath: null,
    ),
    Expense(
      title: 'Restaurant',
      category: 'Food',
      // Dining
      amount: 35.00,
      icon: Icons.restaurant,
      color: Colors.blue[200],
      date: DateTime(2025, 10, 15),
      // Recent
      note: 'Dining',
      // imagePath: null,
    ),
    Expense(
      title: 'Movie Ticket',
      category: 'Entertainment',
      amount: 15.00,
      icon: Icons.movie,
      color: Colors.blue[100],
      date: DateTime(2025, 10, 14),
      note: 'Entertainment',
      // imagePath: null,
    ),
    Expense(
      title: 'Clothing Store',
      category: 'Shopping',
      amount: 75.00,
      icon: Icons.shopping_bag,
      color: Colors.blue[500],
      date: DateTime(2025, 10, 10),
      note: 'Shopping',
      // imagePath: null,
    ),
  ];

  DateTimeRange? _filterRange; // Date filter from FilterScreen
  String _selectedCategory = 'All'; // Selected tab category
  String _searchQuery = ''; // Current search query
  SortType _sortType =
      SortType.dateDesc; // Current sort (date descending by default)

  // Tab categories: Fixed as per design
  final List<String> _tabCategories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Entertainment',
  ];

  // Computed: Filtered and sorted expenses
  List<Expense> get _filteredExpenses {
    var filtered = _allExpenses.where((expense) {
      // Date filter
      if (_filterRange != null) {
        final date = expense.date;
        if (date == null) return false;

        final rangeStart = _filterRange!.start.subtract(
          const Duration(days: 1),
        );
        final rangeEnd = _filterRange!.end.add(const Duration(days: 1));

        if (!(date.isAfter(rangeStart) && date.isBefore(rangeEnd))) {
          return false;
        }
      }
      // Category filter
      if (_selectedCategory != 'All' && expense.category != _selectedCategory) {
        return false;
      }
      // Search filter (title or note)
      if (_searchQuery.isNotEmpty) {
        return expense.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            (expense.note?.toLowerCase() ?? '').contains(
              _searchQuery.toLowerCase(),
            );
      }
      if (_searchQuery.isNotEmpty) {
        final queryLower = _searchQuery.toLowerCase();
        return expense.title.toLowerCase().contains(queryLower) ||
            (expense.note?.toLowerCase().contains(queryLower) ?? false);
      }
      return true;
    }).toList();

    // Sort
    switch (_sortType) {
      //Option 1: Put null dates at the bottom
      case SortType.dateDesc:
        filtered.sort((a, b) {
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });
        break;

      case SortType.dateAsc:
        filtered.sort((a, b) {
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return a.date!.compareTo(b.date!);
        });
        break;
      //Option 2: Treat null dates as the earliest date
      /* case SortType.dateDesc:
        filtered.sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
        break;

      case SortType.dateAsc:
        filtered.sort((a, b) => (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0)));
        break;*/

      case SortType.amountDesc:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortType.amountAsc:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  // Functionality: Navigate to FilterScreen and update date filter on apply (navigate back to this screen implicitly via pop)
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
            'Date filter applied: ${DateFormat('MMM yyyy').format(range.start)}',
          ),
        ),
      );
    }
  }

  // Functionality: Show search delegate for querying expenses
  void _showSearch() {
    showSearch(
      context: context,
      delegate: ExpenseSearchDelegate(
        expenses: _allExpenses,
        onQueryChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  // Functionality: Show sort dialog and update sort type
  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date (Newest First)'),
              leading: Radio<SortType>(
                value: SortType.dateDesc,
                groupValue: _sortType,
                onChanged: (value) {
                  setState(() => _sortType = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Date (Oldest First)'),
              leading: Radio<SortType>(
                value: SortType.dateAsc,
                groupValue: _sortType,
                onChanged: (value) {
                  setState(() => _sortType = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Amount (Highest First)'),
              leading: Radio<SortType>(
                value: SortType.amountDesc,
                groupValue: _sortType,
                onChanged: (value) {
                  setState(() => _sortType = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Amount (Lowest First)'),
              leading: Radio<SortType>(
                value: SortType.amountAsc,
                groupValue: _sortType,
                onChanged: (value) {
                  setState(() => _sortType = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Functionality: Navigate to AddExpenseScreen and add new expense
  void _navigateToAddExpense() {
    Navigator.of(context)
        .push<Expense>(
          MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
        )
        .then((result) {
          if (result is Expense) {
            setState(() {
              _allExpenses.add(result);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Expense added successfully!')),
            );
          }
        });
  }

  // Functionality: Handle category tab selection
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // Functionality: Navigate to details for editing
  void _onExpenseTap(int index) {
    final filtered = _filteredExpenses;
    if (index < filtered.length) {
      final expense = filtered[index];
      final originalIndex = _allExpenses.indexOf(expense);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ExpenseDetailsScreen(
            expense: expense,
            index: originalIndex,
            onUpdate: (idx, updated) {
              setState(() {
                _allExpenses[idx] = updated;
              });
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _filteredExpenses;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.blue),
            onPressed: _navigateToFilter, // Date filter navigation
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: _showSearch, // Search functionality
          ),
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort, color: Colors.blue),
            onSelected: (value) => setState(() => _sortType = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortType.dateDesc,
                child: Text('Date (Newest)'),
              ),
              const PopupMenuItem(
                value: SortType.dateAsc,
                child: Text('Date (Oldest)'),
              ),
              const PopupMenuItem(
                value: SortType.amountDesc,
                child: Text('Amount (High)'),
              ),
              const PopupMenuItem(
                value: SortType.amountAsc,
                child: Text('Amount (Low)'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: _navigateToAddExpense,
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
              itemCount: _tabCategories.length,
              itemBuilder: (context, index) {
                final category = _tabCategories[index];
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
            child: filteredExpenses.isEmpty
                ? const Center(child: Text('No expenses found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredExpenses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return _buildExpenseCard(
                        expense,
                        () => _onExpenseTap(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helper: Build expense card with icon, title, category, amount, formatted date
  Widget _buildExpenseCard(Expense expense, VoidCallback onTap) {
    final dateStr = _formatDate(expense.date ?? DateTime.now());
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon in light blue circle
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: 20,
                child: Icon(expense.icon, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              // Title and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      expense.note??"$expense.category", // Category label
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Amount and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-\$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Format date to "Today", "Yesterday", or "MMM dd"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}
