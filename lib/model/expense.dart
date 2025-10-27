import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/* ----------------------------------------------------------
   Plain data object that represents one purchase
// Data Model: ExpenseItem for recent expenses
   ---------------------------------------------------------- */
import 'package:flutter/material.dart';

class Expense {
  final String? id; // Firestore doc-id (null until saved)
  final String title;
  final String category;
  final double amount;
  final IconData icon;
  final Color? color;
  final DateTime date;
  final String? note;
  final String? imagePath;

  Expense({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.icon,
    this.color,
    required this.date,
    this.note,
    this.imagePath,
  });

  // From Firestore Map (for reading)
  factory Expense.fromMap(Map<String, dynamic> map, String docId) {
    return Expense(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      icon: IconData(
        map['icon'] ?? Icons.money.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: map['color'] != null ? Color(map['color']) : Colors.blue,
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'],
      imagePath: map['imagePath'],
    );
  }

  // To Firestore Map (for writing)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'icon': icon.codePoint,
      'color': color?.value ?? Colors.blue.value,
      'date': Timestamp.fromDate(date),
      'note': note,
      'imagePath': imagePath,
    };
  }

  /* helper for copy-with (used in edit screen) */
  Expense copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    IconData? icon,
    Color? color,
    DateTime? date,
    String? note,
    String? imagePath,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      date: date ?? this.date,
      note: note ?? this.note,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  // Helpers for IconData/Color serialization
  static IconData? _iconFromString(String? iconStr) {
    if (iconStr == null) return null;
    switch (iconStr) {
      case 'Icons.shopping_bag':
        return Icons.shopping_bag;
      // Add more based on categories, e.g., 'Icons.local_gas_station' for Gas
      default:
        return Icons.shopping_bag;
    }
  }

  static String? _iconToString(IconData? icon) {
    if (icon == null) return null;
    return icon.toString();
  }

  static Color? _colorFromString(String? colorStr) {
    if (colorStr == null) return null;
    final intValue = int.tryParse(colorStr);
    return intValue != null ? Color(intValue) : Colors.blue[300];
  }

  static String? _colorToString(Color? color) {
    return color?.value.toString();
  }
}

// Factory for converting Firestore or JSON maps to Expense
//   factory Expense.fromMap(Map<String, dynamic> map, String docId) {
//     return Expense(
//       id: docId,
//       title: map['title'] ?? '',
//       category: map['category'] ?? '',
//       amount: (map['amount'] ?? 0).toDouble(),
//       date: DateTime.parse(map['date']),
//       note: map['note'],
//       imageUrl: map['imageUrl'],
//     );
//   }
//
//   // For saving/uploading to Firestore or JSON
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'category': category,
//       'amount': amount,
//       'date': date,
//       // 'date': date.toIso8601String(),
//       'note': note,
//       'imageUrl': imageUrl,
//     };
//   }
// }
