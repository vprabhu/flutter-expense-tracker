import 'package:flutter/material.dart';
import '../core/dummy_data.dart';

/* ----------------------------------------------------------
   Two cards: "Total Spent"  &  "Food"
   ---------------------------------------------------------- */
class SummaryRow extends StatelessWidget {
  const SummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _card('Total Spent', totalSpent, const Color(0xFF1976D2))),
        const SizedBox(width: 12),
        Expanded(child: _card('Food', totalForCategory('Food'), const Color(0xFF42A5F5))),
      ],
    );
  }

  Widget _card(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: color.withOpacity(0.8))),
          const SizedBox(height: 6),
          Text('\$${value.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }
}