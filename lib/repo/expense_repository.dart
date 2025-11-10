import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../model/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/notifiers/add_expense_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepository());

final expensesNotifierProvider = AsyncNotifierProvider<ExpensesNotifier, List<Expense>>(() => ExpensesNotifier());


class ExpenseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get current user's collection
  CollectionReference<Map<String, dynamic>> get _userExpensesCollection {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user signed in');
    return _db.collection('users').doc(user.uid).collection('expenses');
  }

  // Create: Add and return Expense with auto-generated ID
  Future<Expense> addExpense(Expense expense) async {
    final docRef = await _userExpensesCollection.add(expense.toMap());
    final doc = await docRef.get();
    return Expense.fromMap(doc.data()!, doc.id);
  }

  // Read: Get all expenses for the current user
  Stream<List<Expense>> getExpensesStream() {
    return _userExpensesCollection.snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // Read single by ID
  Future<Expense?> getExpenseById(String id) async {
    final doc = await _userExpensesCollection.doc(id).get();
    if (doc.exists) {
      return Expense.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Update by ID
  Future<void> updateExpense(String id, Expense expense) async {
    await _userExpensesCollection.doc(id).update(expense.toMap());
  }

  // Delete by ID
  Future<void> deleteExpense(String id) async {
    await _userExpensesCollection.doc(id).delete();
  }
}


/*
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
}*/
