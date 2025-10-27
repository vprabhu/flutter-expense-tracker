import 'package:flutter/material.dart';

import '../model/expense.dart';
import '../model/notifiers/add_expense_notifier.dart';
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

  final _categories = ['Food', 'Grocery', 'Gas', 'Movie', 'Electricity', 'Clothing'];

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

    await ref.read(expensesNotifierProvider.notifier).updateExpense(updated.id!, updated);

    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved ✅')));
    setState(() => _isEditing = false);
  }

  /* ----------------------------------------------------------
     Delete from Firestore
     ---------------------------------------------------------- */
  Future<void> _delete() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete expense?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
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
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true))
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _save),
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
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v),
            decoration: const InputDecoration(labelText: 'Category'),
            validator: (v) => v == null ? 'Pick category' : null,
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
            label: const Text('Save changes'),
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


/*
// ExpenseDetailsScreen: View and edit expense details with toggle mode
class ExpenseDetailsScreen1 extends StatefulWidget {
  final Expense expense;
  final int index;
  final void Function(int, Expense) onUpdate;

  const ExpenseDetailsScreen1({
    super.key,
    required this.expense,
    required this.index,
    required this.onUpdate,
  });

  @override
  State<ExpenseDetailsScreen1> createState() => _ExpenseDetailsScreenState1();
}

class _ExpenseDetailsScreenState1 extends State<ExpenseDetailsScreen1> {
  bool _isEditing = false;
  late Expense _originalExpense;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  late TextEditingController _dateController;
  late TextEditingController _noteController;
  String? _selectedCategory;
  DateTime? _selectedDate;
  // File? _receiptImage;

  final List<String> _categories = ['Food', 'Grocery', 'Gas', 'Movie', 'Electricity', 'Clothing'];

  @override
  void initState() {
    super.initState();
    _originalExpense = widget.expense;
    _amountController = TextEditingController(text: _originalExpense.amount.toStringAsFixed(2));
    _selectedCategory = _originalExpense.category;
    _selectedDate = _originalExpense.date;
    _dateController = TextEditingController(text: _originalExpense.date.toString());
    // _dateController = TextEditingController(text: DateFormat('MMMM d, yyyy').format(_originalExpense.date));
    _noteController = TextEditingController(text: _originalExpense.note);
    // if (_originalExpense.imagePath != null) {
    //   _receiptImage = File(_originalExpense.imagePath!);
    // }
  }

  // Toggle edit mode: Set controllers from original
  void _toggleEdit() {
    if (_isEditing) {
      // Save if valid
      if (_formKey.currentState!.validate()) {
        final updatedExpense = Expense(
          title: _originalExpense.title, // Merchant unchanged
          category: _selectedCategory!,
          amount: double.parse(_amountController.text),
          icon: _originalExpense.icon,
          color: _originalExpense.color,
          date: _selectedDate!,
          note: _noteController.text.trim(),
          // imagePath: _receiptImage?.path ?? _originalExpense.imagePath,
        );
        widget.onUpdate(widget.index, updatedExpense);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense updated!')),
        );
      } else {
        return; // Don't exit if invalid
      }
    }
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Revert to original if canceled (but since no cancel, assume save only)
      }
    });
  }

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
        _dateController.text = (date.year+date.month+date.day) as String;
        // _dateController.text = DateFormat('MMMM d, yyyy').format(date);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final icon = Icons.shopping_bag; // Customize based on category if needed
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? _buildEditMode()
            : _buildViewMode(icon),
      ),
    );
  }

  // View mode: Display details as per design
  Widget _buildViewMode(IconData icon) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount with icon circle
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue[100],
                child: Icon(icon, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Shopping', style: TextStyle(fontSize: 14, color: Colors.grey)), // Placeholder; use category
                  Text(
                    '\$${_originalExpense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Category row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Category', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(_originalExpense.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          // Date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Date', style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(_originalExpense.date.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              // Text(DateFormat('MMMM d, yyyy').format(_originalExpense.date), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          // Note section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Note', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _originalExpense.note.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Image/Receipt
         */
/* if (_originalExpense.imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_originalExpense.imagePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else*//*

            // Placeholder for no image: Green container simulating food image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 50,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  // Edit mode: Form fields similar to Add
  Widget _buildEditMode() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '\$ ',
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter an amount';
                final amt = double.tryParse(value);
                if (amt == null || amt <= 0) return 'Please enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
              validator: (value) => value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),
            // Date Field
            TextFormField(
              readOnly: true,
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_drop_down),
                  onPressed: _pickDate,
                ),
              ),
              validator: (value) => _selectedDate == null ? 'Please select a date' : null,
            ),
            const SizedBox(height: 16),
            // Note Field
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.trim().isEmpty ?? true ? 'Please add a note' : null,
            ),
            const SizedBox(height: 24),
            // Upload Receipt Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('Upload Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    const Text('Add a photo of your receipt', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    // ElevatedButton.icon(
                    //   onPressed: _uploadReceipt,
                    //   icon: const Icon(Icons.upload, size: 18),
                    //   label: const Text('Upload'),
                    //   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
                    // ),
                    // if (_receiptImage != null) ...[
                    //   const SizedBox(height: 8),
                    //   Text('Image: ${_receiptImage!.path.split('/').last}'),
                    // ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

*/
