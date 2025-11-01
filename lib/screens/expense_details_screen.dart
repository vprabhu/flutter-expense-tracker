import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../model/expense.dart';
import '../model/notifiers/add_expense_notifier.dart';
import '../utils/Constants.dart';

/// A screen that displays the details of a single expense and allows the user
/// to edit or delete it.
class ExpenseDetailsScreen extends ConsumerStatefulWidget {
  /// The expense to display.
  final Expense expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  ConsumerState<ExpenseDetailsScreen> createState() =>
      _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends ConsumerState<ExpenseDetailsScreen> {
  // A working copy of the expense, used to hold pending changes while editing.
  late Expense _working; 
  // A global key for the form, used to validate the form fields.
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for the form fields.
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _dateCtrl;

  // The currently selected category and date for the expense.
  String? _selectedCategory;
  DateTime? _selectedDate;

  // A boolean to toggle between view and edit mode.
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize the working copy and the text editing controllers.
    _working = widget.expense;
    _amountCtrl = TextEditingController(text: _working.amount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: _working.note ?? '');
    _dateCtrl = TextEditingController(text: DateFormat.yMMMd().format(_working.date));
    _selectedCategory = _working.category;
    _selectedDate = _working.date;
  }

  /// Saves the changes to the expense.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = _working.copyWith(
      amount: double.parse(_amountCtrl.text),
      category: _selectedCategory!,
      date: _selectedDate!,
      note: _noteCtrl.text.trim(),
    );

    if (updated.id == null) return;

    // Update the expense in the database.
    await ref.read(expensesNotifierProvider.notifier).updateExpense(updated.id!, updated);
    if (!mounted) return;

    // Show a confirmation message and exit edit mode.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved ✅')));
    setState(() {
      _isEditing = false;
      _working = updated;
    });
  }

  /// Deletes the expense.
  Future<void> _delete() async {
    // Show a confirmation dialog before deleting.
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (yes != true) return;

    // Delete the expense from the database.
    await ref.read(expensesNotifierProvider.notifier).deleteExpense(_working.id!);
    if (!mounted) return;

    // Go back to the previous screen and show a confirmation message.
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted 🗑️')));
  }

  /// Shows a date picker to allow the user to select a new date.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateCtrl.text = DateFormat.yMMMd().format(picked);
    });
  }

  // Builds the UI for the screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Expense Details'),
        actions: [
          // Show an edit button if not in edit mode.
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
          // Show a delete button.
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // Show the edit form or the view mode based on the `_isEditing` flag.
        child: _isEditing ? _editForm() : _viewMode(),
      ),
    );
  }

  /// Builds the UI for the view mode.
  Widget _viewMode() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The header section with the expense icon, category, and amount.
            Row(
              children: [
                CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Icon(_working.icon, color: Colors.blue, size: 24)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_working.category, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('\u20B9${_working.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // The details section with the category, date, and note.
            _row('Category', _working.category),
            _row('Date', DateFormat.yMMMd().format(_working.date)),
            _row('Note', _working.note ?? '–'),
            const SizedBox(height: 24),
            // A placeholder for the receipt image.
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long, size: 50, color: Colors.white),
            ),
          ],
        ),
      );

  /// A helper method to build a row in the details section.
  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      );

  /// Builds the UI for the edit mode.
  Widget _editForm() => Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The amount field.
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\u20B9 '),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // The category dropdown.
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: Constants.categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              // The date field.
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                ),
              ),
              const SizedBox(height: 16),
              // The note field.
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: 24),
              // The save button.
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Update'),
              ),
            ],
          ),
        ),
      );

  // Dispose of the controllers when the widget is removed from the widget tree.
  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }
}
