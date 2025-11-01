import 'package:intl/intl.dart';

/// A collection of utility functions for formatting dates.

/// Formats a [DateTime] object into a user-friendly string such as "Today",
/// "Yesterday", or a specific date like "Oct 26".
///
/// [date] The date to be formatted.
///
/// Returns a formatted string representation of the date.
String formatDate(DateTime date) {
  final now = DateTime.now();
  // Check if the date is today.
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return 'Today';
    // Check if the date was yesterday.
  } else if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    return 'Yesterday';
  } else {
    // Otherwise, format the date as "MMM dd" (e.g., "Oct 26").
    return DateFormat('MMM dd').format(date);
  }
}

/// Formats a [DateTime] object into a full calendar date string, such as
/// "October 26, 2023".
///
/// [date] The date to be formatted.
///
/// Returns a formatted string representation of the date.
String formatCalendarDate(DateTime date) {
  return DateFormat('MMMM dd, yyyy').format(date);
}
