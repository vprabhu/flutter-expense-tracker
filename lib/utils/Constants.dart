import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';

// Enum for sorting options
enum SortType { dateDesc, dateAsc, amountDesc, amountAsc }

class Constants {
  static const List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Entertainment',
    'Electricity',
    'Grocery',
  ];
  // Tab categories: Fixed as per design
  static const List<String>  tabCategories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Entertainment',
    'Electricity',
    'Grocery',
  ];
}
