import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';

// ExpenseSearchDelegate: Custom SearchDelegate for searching expenses
class ExpenseSearchDelegate extends SearchDelegate<String> {
  final List<Expense> expenses;
  final ValueChanged<String> onQueryChanged;

  ExpenseSearchDelegate({required this.expenses, required this.onQueryChanged});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onQueryChanged('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {

    final results = expenses.where((expense) {
      final title = expense.title.toLowerCase();
      final note = expense.note?.toLowerCase() ?? ''; // null-safe
      final search = query.toLowerCase();
      return title.contains(search) || note.contains(search);
    }).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final expense = results[index];
        return ListTile(
          title: Text(expense.title),
          subtitle: Text('${expense.note} - \$${expense.amount}'),
          onTap: () => close(context, query),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onQueryChanged(query); // Update parent query
    return const SizedBox(); // Suggestions not implemented; use results
  }
}

