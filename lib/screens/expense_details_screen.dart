import 'package:flutter/material.dart';

import '../model/expense.dart';
import '../widgets/bottom_bar.dart';


// ExpenseDetailsScreen: View and edit expense details with toggle mode
class ExpenseDetailsScreen extends StatefulWidget {
  final Expense expense;
  final int index;
  final void Function(int, Expense) onUpdate;

  const ExpenseDetailsScreen({
    super.key,
    required this.expense,
    required this.index,
    required this.onUpdate,
  });

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
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

/*  Future<void> _uploadReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt updated!')),
      );
    }
  }*/

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
          else*/
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