import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repo/expense_repository.dart';
import '../expense.dart';

/// A provider that creates and exposes an instance of [ExpenseRepository].
///
/// This allows other providers and widgets to access the repository for interacting
/// with the Firestore database.
final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepository(),
);

/// A provider for the [ExpensesNotifier], which manages the state of the expenses list.
///
/// This is an [AsyncNotifierProvider], which is ideal for handling asynchronous
/// data streams, such as those from Firestore. It automatically manages loading,
/// error, and data states.
final expensesNotifierProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<Expense>>(
  ExpensesNotifier.new,
);

/// A notifier class that contains the business logic for managing the list of expenses.
///
/// This class handles fetching, adding, updating, and deleting expenses. It uses
/// the [ExpenseRepository] to interact with the database and exposes the data
/// as an [AsyncValue], which can be easily consumed by the UI.
class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  /// The build method is called when the provider is first read.
  ///
  /// It sets up the stream of expenses from the repository and returns it.
  /// The [AsyncNotifierProvider] will automatically handle the stream's states
  /// (loading, data, error) and expose them to the UI.
  @override
  Future<List<Expense>> build() async {
    // Return the stream of expenses from the repository.
    return ref.read(expenseRepositoryProvider).getExpensesStream().first;
  }

  /// Adds a new expense to the database.
  ///
  /// This method sets the state to loading, then attempts to add the expense
  /// using the repository. If successful, it returns the saved expense. If an
  /// error occurs, it sets the state to an error state and returns null.
  Future<Expense?> addExpense(Expense expense) async {
    // Set the state to loading to indicate that an operation is in progress.
    state = const AsyncValue.loading();
    try {
      // Attempt to add the expense using the repository.
      final saved = await ref.read(expenseRepositoryProvider).addExpense(expense);
      return saved;
    } catch (err, st) {
      // If an error occurs, set the state to an error state and return null.
      state = AsyncValue.error(err, st);
      return null;
    }
  }

  /// Updates an existing expense in the database.
  ///
  /// This method sets the state to loading, then attempts to update the expense
  /// using the repository. The stream will automatically emit the new list, so
  /// there's no need to manually update the state on success.
  Future<void> updateExpense(String id, Expense updated) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(expenseRepositoryProvider).updateExpense(id, updated);
    } catch (err, st) {
      state = AsyncValue.error(err, st);
    }
  }

  /// Deletes an expense from the database.
  ///
  /// This method sets the state to loading, then attempts to delete the expense
  /// using the repository. The stream will automatically emit the new list, so
  /// there's no need to manually update the state on success.
  Future<void> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(expenseRepositoryProvider).deleteExpense(id);
    } catch (err, st) {
      state = AsyncValue.error(err, st);
    }
  }
}
