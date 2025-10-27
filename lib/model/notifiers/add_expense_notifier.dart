
import 'package:flutter/material.dart';

import '../../repo/expense_repository.dart';
import '../expense.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';   // Adjust path

// Provider for the repository (dependency injection)
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepository());

// AsyncNotifierProvider for the expenses list (handles loading/error/data)
final expensesNotifierProvider = AsyncNotifierProvider<ExpensesNotifier, List<Expense>>(
      () => ExpensesNotifier(),
);

// AsyncNotifier class (business logic for list)
class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() async {
    /* Listen to the stream and expose AsyncValue automatically */
    ref.listenSelf((previous, next) {
      // keep provider rebuilds minimal
    });

    final stream = ref.read(expenseRepositoryProvider).getExpensesStream();
    stream.listen(
          (list) => state = AsyncValue.data(list),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );

    /* initial empty list until first emit from Firestore */
    return [];
  }

  /* ----------  CRUD wrappers  ---------- */
  Future<Expense?> addExpense(Expense expense) async {
    state = const AsyncValue.loading();
    try {
      final saved = await ref.read(expenseRepositoryProvider).addExpense(expense);
      return saved;
    } catch (err, st) {
      state = AsyncValue.error(err, st);
      return null;
    }
  }

  Future<void> updateExpense(String id, Expense updated) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(expenseRepositoryProvider).updateExpense(id, updated);
      /* Stream will auto-emit new list → state = data */
    } catch (err, st) {
      state = AsyncValue.error(err, st);
    }
  }

  Future<void> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(expenseRepositoryProvider).deleteExpense(id);
    } catch (err, st) {
      state = AsyncValue.error(err, st);
    }
  }
}
