import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';

/// A custom [SearchDelegate] for searching through a list of expenses.
///
/// This class provides a search interface that allows the user to search for
/// expenses by their title or note. It displays the search results in a list
/// and allows the user to select a result.
class ExpenseSearchDelegate extends SearchDelegate<String> {
  /// The list of expenses to search through.
  final List<Expense> expenses;

  /// A callback function that is called when the search query changes.
  final ValueChanged<String> onQueryChanged;

  /// Creates an instance of the [ExpenseSearchDelegate] class.
  ExpenseSearchDelegate({required this.expenses, required this.onQueryChanged});

  /// Builds the actions for the app bar, which in this case is a clear button
  /// to clear the search query.
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

  /// Builds the leading widget for the app bar, which is a back button to
  /// close the search interface.
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  /// Builds the search results based on the current search query.
  @override
  Widget buildResults(BuildContext context) {
    // Filter the expenses based on the search query.
    final results = expenses.where((expense) {
      final title = expense.title.toLowerCase();
      final note = expense.note?.toLowerCase() ?? '';
      final search = query.toLowerCase();
      return title.contains(search) || note.contains(search);
    }).toList();

    // If there are no results, display a message to the user.
    if (results.isEmpty) {
      return const Center(
        child: Text('No expenses found.'),
      );
    }

    // Display the search results in a list.
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final expense = results[index];
        return ListTile(
          title: Text(expense.title),
          subtitle: Text('${expense.note} - \u20B9${expense.amount}'),
          onTap: () => close(context, query),
        );
      },
    );
  }

  /// Builds the suggestions that are displayed while the user is typing.
  @override
  Widget buildSuggestions(BuildContext context) {
    // Notify the parent widget of the query change so it can update its state.
    onQueryChanged(query);
    // In this implementation, we don't show suggestions, but instead, the
    // results are displayed directly on the underlying screen as the user types.
    return const SizedBox();
  }
}
