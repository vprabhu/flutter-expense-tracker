import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/model/notifiers/add_expense_notifier.dart';

import '../utils/formatters.dart';

/// A full-screen modal for adding a new expense.
///
/// This screen provides a form with fields for the expense title, amount,
/// category, date, and an optional note. It includes form validation and handles
/// the logic for saving the new expense to the database.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  // A global key for the form, used to validate the form fields.
  final _formKey = GlobalKey<FormState>();
  // Text editing controllers for the form fields.
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  // The currently selected category for the expense.
  String? _selectedCategory;
  // The currently selected date for the expense.
  DateTime? _selectedDate = DateTime.now();

  /// Displays a date picker and updates the `_selectedDate`.
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  /// Saves the new expense to the database.
  ///
  /// This method first validates the form. If the form is valid, it creates a
  /// new [Expense] object and calls the `addExpense` method on the
  /// [ExpensesNotifier]. It also provides user feedback through SnackBars.
  Future<void> _saveExpense() async {
    // Validate the form. If it's not valid, do nothing.
    if (!_formKey.currentState!.validate()) return;

    // Create a new Expense object from the form data.
    final newExpense = Expense(
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      amount: double.parse(_amountController.text),
      icon: Icons.shopping_bag, // A default icon.
      color: Colors.blue[300], // A default color.
      date: _selectedDate!,
      note: _noteController.text.trim(),
    );

    // Show a progress indicator while the expense is being saved.
    final navigator = Navigator.of(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saving…')));

    // Call the addExpense method on the notifier to save the expense.
    final saved = await ref.read(expensesNotifierProvider.notifier).addExpense(newExpense);

    // Provide feedback to the user based on whether the save was successful.
    if (saved != null) {
      navigator.pop(); // Close the add expense screen.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Expense saved!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save')));
    }
  }

  /// A callback function to cancel the process and close the screen.
  void _cancel() => Navigator.of(context).pop();

  // The build method describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        // A close button to dismiss the screen.
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: _cancel,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A text field for the expense title.
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                // A text field for the expense amount.
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '\u20B9 ', // The Indian Rupee symbol.
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter an amount';
                    final amt = double.tryParse(value);
                    if (amt == null || amt <= 0)
                      return 'Please enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // A dropdown to select the expense category.
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: Constants.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                // A text field to display the selected date.
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    // Format the date for display.
                    text: formatCalendarDate(_selectedDate!),
                  ),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: _pickDate,
                    ),
                  ),
                  validator: (value) =>
                      _selectedDate == null ? 'Please select a date' : null,
                ),
                const SizedBox(height: 16),
                // A text field for an optional note.
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Please add a note' : null,
                ),
                const SizedBox(height: 24),
                // A card for uploading a receipt.
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload Receipt',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add a photo of your receipt',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // The cancel and save buttons.
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dispose of the text editing controllers when the widget is removed from the widget tree.
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
