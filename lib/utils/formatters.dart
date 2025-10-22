import 'package:intl/intl.dart';


// Helper: Format date to "Today", "Yesterday", or "MMM dd"
String formatDate(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day) {
    return 'Today';
  } else if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day - 1) {
    return 'Yesterday';
  } else {
    return DateFormat('MMM dd').format(date);
  }
}
String formatCalendarDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
}

