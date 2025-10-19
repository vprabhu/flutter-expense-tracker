import 'package:flutter/material.dart';

// FilterExpensesScreen: Modal for filtering expenses by month or custom date range
// Structure: Segmented buttons for quick months, conditional date pickers for custom, applies DateTimeRange
class FilterExpensesScreen extends StatefulWidget {
  final DateTimeRange? initialRange;

  const FilterExpensesScreen({
    super.key,
    this.initialRange,
  });

  @override
  State<FilterExpensesScreen> createState() => _FilterExpensesScreenState();
}

class _FilterExpensesScreenState extends State<FilterExpensesScreen> {
  String _selectedMonth = 'Current Month'; // Initial selection
  bool _showCustom = false;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _monthOptions = ['All', 'Current Month', 'Last Month', 'Custom'];

  @override
  void initState() {
    super.initState();
    // Restore initial state if provided
    if (widget.initialRange != null) {
      _startDate = widget.initialRange!.start;
      _endDate = widget.initialRange!.end;
      _selectedMonth = 'Custom';
      _showCustom = true;
    } else {
      // Default to current month
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
    }
  }

  // Functionality: Handle month selection - toggle custom date range visibility
  void _onMonthSelected(String value) {
    setState(() {
      _selectedMonth = value;
      _showCustom = value == 'Custom';
      if (value == 'Custom' && _startDate == null) {
        // Default to current month for custom
        final now = DateTime.now();
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
      }
    });
  }

  // Functionality: Select start date
  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  // Functionality: Select end date (ensure >= start)
  Future<void> _selectEndDate() async {
    final initial = _endDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  // Functionality: Compute and apply filter range based on selection, then pop
  void _applyFilters() {
    DateTimeRange? range;
    final now = DateTime.now();
    switch (_selectedMonth) {
      case 'All':
        range = null; // Clear filter
        break;
      case 'Current Month':
        final currentStart = DateTime(now.year, now.month, 1);
        final currentEnd = DateTime(now.year, now.month + 1, 0);
        range = DateTimeRange(start: currentStart, end: currentEnd);
        break;
      case 'Last Month':
        final lastMonth = now.month == 1 ? DateTime(now.year - 1, 12, 1) : DateTime(now.year, now.month - 1, 1);
        final lastEnd = DateTime(lastMonth.year, lastMonth.month + 1, 0);
        range = DateTimeRange(start: lastMonth, end: lastEnd);
        break;
      case 'Custom':
        if (_startDate != null && _endDate != null && _startDate!.isBefore(_endDate!.add(const Duration(days: 1)))) {
          range = DateTimeRange(start: _startDate!, end: _endDate!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select valid start and end dates')),
          );
          return;
        }
        break;
    }
    Navigator.of(context).pop(range);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Expenses'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selection Section
            const Text(
              'Month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildMonthSegment(),
            // Conditional Date Range for Custom
            if (_showCustom) ...[
              const SizedBox(height: 24),
              const Text(
                'Date Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Start Date Picker
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _startDate != null ? _startDate!.toString() : 'Select Date',
                        // text: _startDate != null ? DateFormat('MMM d, yyyy').format(_startDate!) : 'Select Date',
                      ),
                      onTap: _selectStartDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // End Date Picker
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _endDate != null ? _endDate!.toString() : 'Select Date',
                        // text: _endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : 'Select Date',
                      ),
                      onTap: _selectEndDate,
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper: Build segmented month buttons in two rows
  Widget _buildMonthSegment() {
    return Column(
      children: [
        // First row: All | Current Month
        Row(
          children: [
            Expanded(
              child: _buildMonthButton('All', _selectedMonth == 'All'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMonthButton('Current Month', _selectedMonth == 'Current Month'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Second row: Last Month | Custom
        Row(
          children: [
            Expanded(
              child: _buildMonthButton('Last Month', _selectedMonth == 'Last Month'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMonthButton('Custom', _selectedMonth == 'Custom'),
            ),
          ],
        ),
      ],
    );
  }

  // Helper: Build individual month button (chip-like)
  Widget _buildMonthButton(String label, bool selected) {
    return GestureDetector(
      onTap: () => _onMonthSelected(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}