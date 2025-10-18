import 'package:flutter/material.dart';

/* ----------------------------------------------------------
   Plain data object that represents one purchase
// Data Model: ExpenseItem for recent expenses
   ---------------------------------------------------------- */

class Expense {
  final String? id;
  final String title;
  final String category;
  final double amount;
  final DateTime? date;
  final String? note;
  final String? imageUrl; // For receipt/photo, if needed
  final IconData? icon;
  final Color? color;

  Expense({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    this.date,
    this.note,
    this.imageUrl,
    this.icon,
    this.color,
  });

  // Factory for converting Firestore or JSON maps to Expense
  factory Expense.fromMap(Map<String, dynamic> map, String docId) {
    return Expense(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date']),
      note: map['note'],
      imageUrl: map['imageUrl'],
    );
  }

  // For saving/uploading to Firestore or JSON
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'date': date,
      // 'date': date.toIso8601String(),
      'note': note,
      'imageUrl': imageUrl,
    };
  }
}
