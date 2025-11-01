import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../utils/formatters.dart';

/// A widget that displays a single expense in a card format.
///
/// This widget is used to display a summary of an expense, including its icon,
/// title, category, amount, and date. It also handles tap events to allow the
/// user to view the full details of the expense.
Widget buildExpenseCard(Expense expense, VoidCallback onTap) {
  // Format the date to be displayed in a user-friendly format.
  final dateStr = formatDate(expense.date);

  // An InkWell widget provides the ripple effect when the card is tapped.
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // The expense icon, displayed in a colored circle.
            CircleAvatar(
              backgroundColor: expense.color,
              radius: 20,
              child: Icon(
                expense.icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // The expense title and category.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    expense.category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // The expense amount and date.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- \u20B9${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
