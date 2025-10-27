import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import '../model/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/notifiers/add_expense_notifier.dart';


final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepository());

final expensesNotifierProvider = AsyncNotifierProvider<ExpensesNotifier, List<Expense>>(() => ExpensesNotifier());

class ExpenseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create: Add and return Expense with auto-generated ID
  Future<Expense> addExpense(Expense expense) async {
    final docRef = await _db.collection('expenses').add(expense.toMap());
    final doc = await docRef.get();  // Fetch to get full data + ID
    return Expense.fromMap(doc.data()!, doc.id);
  }

  // Read: Get all expenses (with IDs)
  Stream<List<Expense>> getExpensesStream() {
    return _db.collection('expenses').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Expense.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  // Read single by ID
  Future<Expense?> getExpenseById(String id) async {
    final doc = await _db.collection('expenses').doc(id).get();
    if (doc.exists) {
      return Expense.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Update: By ID
  Future<void> updateExpense(String id, Expense expense) async {
    await _db.collection('expenses').doc(id).update(expense.toMap());
  }

  // Delete: By ID
  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete();
  }
}