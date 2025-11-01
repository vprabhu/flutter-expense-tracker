/// An enumeration of the available sorting options for the expenses list.

enum SortType {
  /// Sort by date in descending order (newest first).
  dateDesc,

  /// Sort by date in ascending order (oldest first).
  dateAsc,

  /// Sort by amount in descending order (highest first).
  amountDesc,

  /// Sort by amount in ascending order (lowest first).
  amountAsc
}

/// A class that contains constant values used throughout the application.
///
/// Using a dedicated constants class helps to avoid magic strings and makes it
/// easier to manage and update these values.
class Constants {
  /// A list of the available expense categories.
  static const List<String> categories = [
    'Food',
    'Travel',
    'Shopping',
    'Entertainment',
    'Electricity',
    'Grocery',
  ];

  /// A list of the categories to be displayed as tabs for filtering.
  ///
  /// This list includes an "All" category to allow the user to view all expenses.
  static const List<String> tabCategories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Entertainment',
    'Electricity',
    'Grocery',
  ];
}
