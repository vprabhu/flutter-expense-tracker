import 'package:expense_tracker/model/expense.dart';
import 'package:flutter/material.dart';

import '../utils/formatters.dart';

// AddExpenseScreen: Full-screen modal for adding new expense
// Structure: Form with validation; on Save, return true to parent for refresh
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate = DateTime.now();
  // File? _receiptImage;
  // Categories for dropdown (matching design data)
  final List<String> _categories = ['Grocery', 'Gas', 'Movie', 'Electricity', 'Clothing'];

  // Default date: Current date (October 18, 2025, as per context)
  @override
  void initState() {
    super.initState();
  }

  // Functionality: Pick date using showDatePicker
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

  // Functionality: Upload receipt - simulate with image picker
/*  Future<void> _uploadReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt uploaded!')),
      );
    }
  }*/

  // Functionality: Save expense - validate form, then pop with success
 /* void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      // Simulate saving (in real app, add to database/list)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saving expense...')),
      );
      Navigator.of(context).pop(true); // Return true to trigger refresh in parent
    }
  }*/
  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final newExpense = Expense(
        title: _merchantController.text.trim(),
        category: _selectedCategory!,
        amount: double.parse(_amountController.text),
        icon: Icons.shopping_bag, // Default; customize based on category
        color: Colors.blue[300],
        date: _selectedDate!,
        note: _noteController.text.trim(),
        // imagePath: _receiptImage?.path,
      );
      Navigator.of(context).pop(newExpense);
    }
  }
  // Functionality: Cancel - pop without saving
  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
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
                /*const SizedBox(height: 8),
                // Merchant Field
                TextFormField(
                  controller: _merchantController,
                  decoration: const InputDecoration(
                    labelText: 'Merchant',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.trim().isEmpty ?? true ? 'Please enter merchant' : null,
                ),*/
                const SizedBox(height: 8),
                // Amount Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '\u20B9 ',
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
                  controller: TextEditingController(text: formatCalendarDate(_selectedDate!)),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                    // prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: _pickDate,
                    ),
                  ),
                  validator: (value) =>  _selectedDate == null ? 'Please select a date' : null,
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
                        //   Text('Image selected: ${_receiptImage!.path.split('/').last}'),
                        // ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Bottom Buttons
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
  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}