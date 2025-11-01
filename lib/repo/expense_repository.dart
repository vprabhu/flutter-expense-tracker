import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/expense.dart';

/// A repository class for managing expense data in Firestore.
///
/// This class encapsulates all the logic for interacting with the Firestore
/// 'expenses' collection, providing a clean API for CRUD (Create, Read, Update,
/// Delete) operations.
class ExpenseRepository {
  // An instance of FirebaseFirestore, the entry point for all Firestore operations.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Adds a new expense to the Firestore collection.
  ///
  /// This method takes an [Expense] object, converts it to a map, and adds it
  /// to the 'expenses' collection. It then fetches the newly created document
  /// to return a complete [Expense] object, including the Firestore-generated ID.
  ///
  /// Returns a [Future] that completes with the saved [Expense] object.
  Future<Expense> addExpense(Expense expense) async {
    final docRef = await _db.collection('expenses').add(expense.toMap());
    final doc = await docRef.get(); // Fetch to get the full data including the ID.
    return Expense.fromMap(doc.data()!, doc.id);
  }

  /// Retrieves a stream of all expenses from the Firestore collection.
  ///
  /// This method listens for real-time updates to the 'expenses' collection.
  /// Whenever the data changes, it emits a new list of [Expense] objects.
  ///
  /// Returns a [Stream] of a list of [Expense] objects.
  Stream<List<Expense>> getExpensesStream() {
    return _db.collection('expenses').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Expense.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Retrieves a single expense by its unique ID.
  ///
  /// This method fetches a specific document from the 'expenses' collection
  /// based on the provided [id].
  ///
  /// Returns a [Future] that completes with the [Expense] object if found,
  /// otherwise returns null.
  Future<Expense?> getExpenseById(String id) async {
    final doc = await _db.collection('expenses').doc(id).get();
    if (doc.exists) {
      return Expense.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Updates an existing expense in the Firestore collection.
  ///
  /// This method takes the [id] of the expense to update and an [Expense] object
  /// containing the new data. It then updates the corresponding document in Firestore.
  ///
  /// Returns a [Future] that completes when the update is finished.
  Future<void> updateExpense(String id, Expense expense) async {
    await _db.collection('expenses').doc(id).update(expense.toMap());
  }

  /// Deletes an expense from the Firestore collection by its ID.
  ///
  /// This method takes the [id] of the expense to delete and removes the
  /// corresponding document from Firestore.
  ///
  /// Returns a [Future] that completes when the deletion is finished.
  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete();
  }
}
