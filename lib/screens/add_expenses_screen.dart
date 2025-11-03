import 'dart:io';

import 'package:expense_tracker/model/expense.dart';
import 'package:expense_tracker/utils/Constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../repo/expense_repository.dart';
import '../utils/formatters.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';  // For ScaffoldMessenger

// AddExpenseScreen: Full-screen modal for adding new expense
// Structure: Form with validation; on Save, return true to parent for refresh
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate = DateTime.now();

  File? _receiptImage;
  String? _receiptUrl;


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

  Future<void> _uploadReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _receiptImage = file;
      });

      // Check file size (ImgBB limit: 32MB)
      int fileSizeInBytes = await file.length();
      if (fileSizeInBytes > 32 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large (max 32MB for ImgBB)')),
        );
        return;
      }

      try {
        // Read image bytes
        List<int> imageBytes = await file.readAsBytes();

        // Replace with your actual API key from imgbb.com
        String apiKey = '388e521a61a69a4e1b459a35107702b3';  // e.g., '12345abcde'
        print('Uploading to ImgBB...');  // Debug log

        String url = 'https://api.imgbb.com/1/upload?key=$apiKey';
        var request = http.MultipartRequest('POST', Uri.parse(url));

        // Add image file
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',  // Must be 'image' field
            imageBytes,
            filename: 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',  // Optional, but good
          ),
        );

        print('Uploading to ImgBB...');  // Debug log
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('Response status: ${response.statusCode}');  // Log status
        print('Response body: ${response.body}');  // Full error details

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          if (data['status'] == 200) {
            String downloadUrl = data['data']['url'];  // HTTP URL like https://i.ibb.co/abc123.jpg

            setState(() {
              _receiptUrl = downloadUrl;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt uploaded to ImgBB!')),
            );
          } else {
            throw Exception('ImgBB API error: ${data['error']['message'] ?? 'Unknown'}');
          }
        } else {
          // Handle 400, 401, etc.
          Map<String, dynamic>? errorData = json.decode(response.body);
          String errorMsg = errorData?['error']['message'] ?? 'HTTP ${response.statusCode}';
          throw Exception('ImgBB upload failed: $errorMsg');
        }
      } on http.ClientException catch (e) {
        print('Network error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error - check connection')),
        );
      } catch (e) {
        print('Upload error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }



  // Functionality: Save expense - validate form, then pop with success
  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final newExpense = Expense(
      title: _merchantController.text.trim(),
      category: _selectedCategory!,
      amount: double.parse(_amountController.text),
      icon: Icons.shopping_bag,
      color: Colors.blue[300],
      date: _selectedDate!,
      note: _noteController.text.trim(),
      imagePath: _receiptUrl,
      // imagePath: _receiptImage?.path,
    );

    /* Show progress indicator while async call runs */
    final navigator = Navigator.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saving…')));

    final saved = await ref
        .read(expensesNotifierProvider.notifier)
        .addExpense(newExpense);

    if (saved != null) {
      navigator.pop(); // close add screen
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense saved!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save')));
    }
  }

  // Functionality: Cancel - pop without saving
  void _cancel() => Navigator.of(context).pop();

  /* ----------------  UI  ---------------- */

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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '\u20B9 ',
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
                // Category Dropdown
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
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                  validator: (value) =>
                      value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                // Date Field
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: formatCalendarDate(_selectedDate!),
                  ),
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
                  validator: (value) =>
                      _selectedDate == null ? 'Please select a date' : null,
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
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Please add a note'
                      : null,
                ),
                const SizedBox(height: 24),
                // Upload Receipt Card
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
                        ElevatedButton.icon(
                          onPressed: _uploadReceipt,
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('Upload'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[50]),
                        ),
                        if (_receiptImage != null || _receiptUrl != null) ...[
                          const SizedBox(height: 16),
                          if (_receiptImage != null && _receiptUrl == null) ...[
                            const Text('Preview Selected Image:'),
                            Stack(
                              children: [
                                SizedBox(
                                  height: 150,
                                  child: Image.file(
                                    _receiptImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 24),
                                    onPressed: () {
                                      setState(() {
                                        _receiptImage = null;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Image removed')),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_receiptUrl != null) ...[
                            const Text('Uploaded Image:'),
                            Stack(
                              children: [
                                Image.network(
                                  _receiptUrl!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const CircularProgressIndicator();
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Error loading uploaded image');
                                  },
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 24),
                                    onPressed: () {
                                      setState(() {
                                        _receiptUrl = null;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Image removed from selection')),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
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
