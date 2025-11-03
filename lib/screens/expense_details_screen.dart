import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  /* ---- image editing ---- */
  File? _editedReceiptImage;
  String? _editedReceiptUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _working = widget.expense;
    _amountCtrl = TextEditingController(
      text: _working.amount.toStringAsFixed(2),
    );
    _noteCtrl = TextEditingController(text: _working.note ?? '');
    _dateCtrl = TextEditingController(
      text: DateFormat.yMMMd().format(_working.date),
    );
    _selectedCategory = _working.category;
    _selectedDate = _working.date;
    print("AAAAA Img ${_working.imagePath}");
  }

  /* ----------------------------------------------------------
     Save changes to Firestore
     ---------------------------------------------------------- */
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Use edited image if changed, else original or null
    String? finalImagePath =
        _editedReceiptUrl ??
        (_working.imagePath?.isNotEmpty == true ? _working.imagePath : null);

    final updated = _working.copyWith(
      amount: double.parse(_amountCtrl.text),
      category: _selectedCategory!,
      date: _selectedDate!,
      note: _noteCtrl.text.trim(),
      imagePath:
          finalImagePath, // Prioritize edited, fallback to original or null
    );

    if (updated.id == null) return;
    await ref
        .read(expensesNotifierProvider.notifier)
        .updateExpense(updated.id!, updated);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved ✅')));
    setState(() {
      _isEditing = false;
      _working = updated; // Update working with final changes, including image
    });

    // Clear edit state
    _editedReceiptImage = null;
    _editedReceiptUrl = null;
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (yes != true) return;

    await ref
        .read(expensesNotifierProvider.notifier)
        .deleteExpense(_working.id!);
    if (!mounted) return;
    Navigator.pop(context); // back to list
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Deleted 🗑️')));
  }

  /* ----------------------------------------------------------
   Update image for editing - pick and upload new
   ---------------------------------------------------------- */
  Future<void> _updateReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _editedReceiptImage = File(pickedFile.path);
        _isUploadingImage = true; // Start loading overlay
      });

      // Check file size (ImgBB limit: 32MB)
      int fileSizeInBytes = await _editedReceiptImage!.length();
      if (fileSizeInBytes > 32 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image too large (max 32MB)')),
        );
        setState(() {
          _editedReceiptImage = null;
          _isUploadingImage = false;
        });
        return;
      }

      try {
        // Read image bytes
        List<int> imageBytes = await _editedReceiptImage!.readAsBytes();

        String apiKey = '388e521a61a69a4e1b459a35107702b3';

        String url = 'https://api.imgbb.com/1/upload?key=$apiKey';
        var request = http.MultipartRequest('POST', Uri.parse(url));

        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );

        print('Uploading new image to ImgBB...');
        var streamedResponse = await request
            .send(); // Send request (no listen here)

        var response = await http.Response.fromStream(
          streamedResponse,
        ); // Consume stream fully

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          if (data['status'] == 200) {
            String newDownloadUrl = data['data']['url'];

            setState(() {
              _editedReceiptUrl = newDownloadUrl;
              _editedReceiptImage = null; // Clear local after success
              _isUploadingImage = false; // Stop loading
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image updated successfully!')),
              );
            }
          } else {
            throw Exception(
              'ImgBB API error: ${data['error']['message'] ?? 'Unknown'}',
            );
          }
        } else {
          Map<String, dynamic>? errorData;
          try {
            errorData = json.decode(response.body);
          } catch (_) {
            // Ignore JSON parse error on non-JSON response
          }
          String errorMsg =
              errorData?['error']?['message'] ??
              'HTTP ${response.statusCode}: ${response.body}';
          throw Exception('ImgBB upload failed: $errorMsg');
        }
      } on http.ClientException catch (e) {
        print('Network/Client error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network error - check connection')),
          );
        }
        setState(() {
          _editedReceiptImage = null;
          _isUploadingImage = false;
        });
      } catch (e) {
        print('Upload error: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
        setState(() {
          _editedReceiptImage = null;
          _isUploadingImage = false;
        });
      }
    }
  }

  /* ----------------------------------------------------------
   Remove the image (existing or edited)
   ---------------------------------------------------------- */
  void _removeImage() {
    setState(() {
      _editedReceiptImage = null;
      _editedReceiptUrl = null;
      _isUploadingImage = false; // Stop any ongoing upload overlay
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image removed')));
    }
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
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
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
              child: Icon(_working.icon, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _working.category,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '\u20B9${_working.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        if (_working.imagePath != null && _working.imagePath!.isNotEmpty)
          Column(
            children: [
              const Text('Uploaded Image:'),
              const SizedBox(height: 10),
              Image.network(
                _working.imagePath!,
                height: 200,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Error loading image'),
              ),
            ],
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
              labelText: 'Amount',
              prefixText: '\u20B9 ',
            ),
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
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
            ),
            items: Constants.categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 16),
          // date
          TextFormField(
            controller: _dateCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // note
          TextFormField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
          const SizedBox(height: 16),
          // image section - single overriding view
          const Text(
            'Receipt Image',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          // Single image slot that overrides based on state
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Stack(
              children: [
                // Determine and show the active image with optional loading overlay
                Builder(
                  builder: (context) {
                    Widget imageWidget;
                    if (_editedReceiptUrl != null) {
                      // New uploaded
                      imageWidget = Image.network(
                        _editedReceiptUrl!,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,

                          color: Colors.grey[200],
                          child: const Center(child: Text('Error loading image')),
                        ),
                      );
                    } else if (_editedReceiptImage != null) {
                      // Local preview with upload overlay
                      imageWidget = Stack(
                        children: [
                          Image.file(
                            _editedReceiptImage!,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          // Upload progress overlay
                          if (_isUploadingImage)
                            Container(
                              height: 150,
                              color: Colors.black26,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Uploading...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    } else if (_working.imagePath != null &&
                        _working.imagePath!.isNotEmpty) {
                      // Original
                      imageWidget = ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _working.imagePath!,
                          height: 150,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 150,

                            color: Colors.grey[200],
                            child: const Center(
                              child: Text('Error loading original image'),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Placeholder
                      imageWidget = Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return imageWidget;
                  },
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Retake button - always visible to trigger picker/upload
            ElevatedButton.icon(
              onPressed: _updateReceiptImage,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(
                (_editedReceiptUrl != null ||
                    _editedReceiptImage != null ||
                    (_working.imagePath != null &&
                        _working.imagePath!.isNotEmpty))
                    ? 'Retake Image'
                    : 'Add Image',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
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
