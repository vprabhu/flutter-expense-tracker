import '../model/expense.dart';

/* ----------------------------------------------------------
   Hard-coded list that matches the PNG 1-for-1
   ---------------------------------------------------------- */
final dummyExpenses = <Expense>[
  Expense(
    category: 'Food',
    amount: 75,
    note: 'Grocery',
    date: DateTime.now().subtract(const Duration(days: 1)),
    id: '', title: '',
  ),
  Expense(
    category: 'Transport',
    note: 'Gas Station',
    amount: 45,
    date: DateTime.now().subtract(const Duration(days: 2)),
    id: '', title: '',

  ),
  Expense(
    category: 'Entertainment',
    amount: 20,
    note: 'Movie',
    date: DateTime.now().subtract(const Duration(days: 3)),
    id: '', title: '',

  ),
  Expense(
    category: 'Utilities',
    amount: 150,
    note: 'Electricity',
    date: DateTime.now().subtract(const Duration(days: 4)),
    id: '', title: '',

  ),
  Expense(
    category: 'Food',
    amount: 100,
    note: 'Clothing',
    date: DateTime.now().subtract(const Duration(days: 5)),
    id: '', title: '',
  ),
];

/* ----------------------------------------------------------
   Quick helpers used by widgets
   ---------------------------------------------------------- */
double get totalSpent =>
    dummyExpenses.fold<double>(0, (sum, e) => sum + e.amount);

double totalForCategory(String cat) => dummyExpenses
    .where((e) => e.category == cat)
    .fold<double>(0, (sum, e) => sum + e.amount);

Map<String, double> categoryTotals() {
  final map = <String, double>{};
  for (final e in dummyExpenses) {
    map.update(e.category, (v) => v + e.amount, ifAbsent: () => e.amount);
  }
  return map;
}