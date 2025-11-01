import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A data model class that represents a single expense record.
///
/// This class is a plain data object (PDO) used to structure expense information
/// throughout the app. It includes methods for serializing to and deserializing
/// from Firestore.
class Expense {
  /// The unique identifier for the expense, typically the Firestore document ID.
  /// This is nullable because a new expense won't have an ID until it's saved.
  final String? id;

  /// The name or description of the expense (e.g., "Coffee").
  final String title;

  /// The category of the expense (e.g., "Food", "Transport").
  final String category;

  /// The monetary value of the expense.
  final double amount;

  /// The icon associated with the expense's category.
  final IconData icon;

  /// The color used for UI elements related to this expense, often tied to the category.
  final Color? color;

  /// The date and time when the expense was incurred.
  final DateTime date;

  /// An optional note containing additional details about the expense.
  final String? note;

  /// An optional file path to an image associated with the expense (e.g., a receipt).
  final String? imagePath;

  /// Creates an instance of the [Expense] class.
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

  /// A factory constructor to create an [Expense] instance from a Firestore document.
  ///
  /// This method safely extracts and type-casts data from a Firestore map.
  /// [map] is the map of data from a Firestore document snapshot.
  /// [docId] is the ID of the Firestore document.
  factory Expense.fromMap(Map<String, dynamic> map, String docId) {
    return Expense(
      id: docId,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      // Ensure amount is a double, defaulting to 0.0 if null or wrong type.
      amount: (map['amount'] ?? 0).toDouble(),
      // Recreate IconData from the stored integer code point.
      icon: IconData(
        map['icon'] ?? Icons.money.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      // Recreate Color from the stored integer value.
      color: map['color'] != null ? Color(map['color']) : Colors.blue,
      // Convert Firestore Timestamp to a Dart DateTime object.
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'],
      imagePath: map['imagePath'],
    );
  }

  /// Converts this [Expense] instance into a map for storing in Firestore.
  ///
  /// This method prepares the data for serialization, converting objects like
  /// [DateTime], [IconData], and [Color] into Firestore-compatible types.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      // Store the integer code point of the icon, not the object itself.
      'icon': icon.codePoint,
      // Store the integer value of the color.
      'color': color?.value ?? Colors.blue.value,
      // Convert DateTime to Firestore Timestamp for proper querying.
      'date': Timestamp.fromDate(date),
      'note': note,
      'imagePath': imagePath,
    };
  }

  /// Creates a copy of this [Expense] instance with specified fields updated.
  ///
  /// This is useful for immutably updating an expense record, such as in an
  /// editing screen. Any fields not provided will retain their original values.
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
}
