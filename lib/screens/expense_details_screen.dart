import 'package:flutter/material.dart';

import '../model/expense.dart';
import '../model/notifiers/add_expense_notifier.dart';
import '../utils/Constants.dart';
import '../widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // contains Expense, expensesNotifierProvider, etc.

/* ===================================================================
   Detail screen – reads & writes straight to Firestore
   =================================================================== */
class ExpenseDetailsScreen extends ConsumerStatefulWidget {
  final Expense expense; // must have non-null id
  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  ConsumerState<ExpenseDetailsScreen> createState() =>
      _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends ConsumerState<ExpenseDetailsScreen> {
  late Expense _working; // working copy while editing
  final _formKey = GlobalKey<FormState>();

  /* ---- controllers ---- */
  late TextEditingController _amountCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _dateCtrl;

  /* ---- dropdown & date ---- */
  String? _selectedCategory;
  DateTime? _selectedDate;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _working = widget.expense;
    _amountCtrl = TextEditingController(text: _working.amount.toStringAsFixed(2));
    _noteCtrl = TextEditingController(text: _working.note ?? '');
    _dateCtrl = TextEditingController(text: DateFormat.yMMMd().format(_working.date));
    _selectedCategory = _working.category;
    _selectedDate = _working.date;
  }

  /* ----------------------------------------------------------
     Save changes to Firestore
     ---------------------------------------------------------- */
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = _working.copyWith(
      amount: double.parse(_amountCtrl.text),
      category: _selectedCategory!,
      date: _selectedDate!,
      note: _noteCtrl.text.trim(),
    );

    if (updated.id == null) return;
    await ref.read(expensesNotifierProvider.notifier).updateExpense(updated.id!, updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved ✅')));
    setState(() => _isEditing = false);
    _working = _working.copyWith(
      amount: double.parse(_amountCtrl.text),
      category: _selectedCategory!,
      date: _selectedDate!,
      note: _noteCtrl.text.trim(),
    );
  }

  /* ----------------------------------------------------------
     Delete from Firestore
     ---------------------------------------------------------- */
  Future<void> _delete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure to delete this expense?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (yes != true) return;

    await ref.read(expensesNotifierProvider.notifier).deleteExpense(_working.id!);
    if (!mounted) return;
    Navigator.pop(context); // back to list
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted 🗑️')));
  }

  /* ----------------------------------------------------------
     Pick new date
     ---------------------------------------------------------- */
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

  /* ===================================================================
     Build – toggles between view & edit mode
     =================================================================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Expense Details'),
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
          IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isEditing ? _editForm() : _viewMode(),
      ),
    );
  }

  /* ----------------  VIEW MODE  ---------------- */
  Widget _viewMode() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header
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
                Text(_working.category,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text('\u20B9${_working.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        // rows
        _row('Category', _working.category),
        _row('Date', DateFormat.yMMMd().format(_working.date)),
        _row('Note', _working.note ?? '–'),
        const SizedBox(height: 24),
        // receipt placeholder
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

  /* ----------------  EDIT FORM  ---------------- */
  Widget _editForm() => Form(
    key: _formKey,
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // amount
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
                labelText: 'Amount', prefixText: '\u20B9 '),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter amount';
              final n = double.tryParse(v);
              if (n == null || n <= 0) return 'Invalid amount';
              return null;
            },
          ),
          const SizedBox(height: 16),
          // category
          // Category Dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            items:  Constants.categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) => value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 16),
          // date
          TextFormField(
            controller: _dateCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
            ),
          ),
          const SizedBox(height: 16),
          // note
          TextFormField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Update'),
          ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }
}