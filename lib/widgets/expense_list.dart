import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:flutter/material.dart';

class ExpenseList extends StatelessWidget {
  const ExpenseList({
    super.key,
    required this.expenses,
    required this.onExpenseTap,
  });

  final List<Expense> expenses;
  final void Function(Expense expense) onExpenseTap;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(child: Text('No expenses for this period'));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => buildExpenseCard(
        expenses[i],
        () => onExpenseTap(expenses[i]),
      ),
    );
  }
}
