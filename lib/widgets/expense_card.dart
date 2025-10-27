import 'package:flutter/material.dart';
import '../model/expense.dart';
import '../utils/formatters.dart';

/* ----------------------------------------------------------
   List of recent purchases
   ---------------------------------------------------------- */
// Helper: Build individual expense card
Widget buildExpenseCard(Expense expense, VoidCallback onTap) {
  final dateStr = formatDate(expense.date ?? DateTime.now());

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon with color
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
            // Title and Category
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // Amount and Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- \$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper: Build expense card with icon, title, category, amount, formatted date
Widget _buildExpenseCard(Expense expense, VoidCallback onTap) {
  final dateStr = formatDate(expense.date ?? DateTime.now());
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon in light blue circle
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              radius: 20,
              child: Icon(expense.icon, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            // Title and Category
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
                    expense.note ?? "$expense.category", // Category label
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Amount and Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}