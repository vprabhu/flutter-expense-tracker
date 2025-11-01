import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A screen that allows the user to filter expenses by month or a custom date range.
class FilterExpensesScreen extends StatefulWidget {
  /// The initial date range to display.
  final DateTimeRange? initialRange;

  const FilterExpensesScreen({super.key, this.initialRange});

  @override
  State<FilterExpensesScreen> createState() => _FilterExpensesScreenState();
}

class _FilterExpensesScreenState extends State<FilterExpensesScreen> {
  // The currently selected month filter.
  String _selectedMonth = 'Current Month';
  // A boolean to show or hide the custom date range pickers.
  bool _showCustom = false;
  // The start and end dates for the custom date range.
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // If an initial date range is provided, restore the state.
    if (widget.initialRange != null) {
      _startDate = widget.initialRange!.start;
      _endDate = widget.initialRange!.end;
      _selectedMonth = 'Custom';
      _showCustom = true;
    } else {
      // Otherwise, default to the current month.
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
    }
  }

  /// A callback function that is called when a month is selected.
  void _onMonthSelected(String value) {
    setState(() {
      _selectedMonth = value;
      _showCustom = value == 'Custom';
      // If the user selects "Custom" and no date range is set, default to the current month.
      if (value == 'Custom' && _startDate == null) {
        final now = DateTime.now();
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
      }
    });
  }

  /// Shows a date picker to allow the user to select a start date.
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

  /// Shows a date picker to allow the user to select an end date.
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

  /// Applies the selected filters and returns the date range to the previous screen.
  void _applyFilters() {
    DateTimeRange? range;
    final now = DateTime.now();

    // Calculate the date range based on the selected month.
    switch (_selectedMonth) {
      case 'All':
        range = null; // No filter.
        break;
      case 'Current Month':
        range = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
        break;
      case 'Last Month':
        final lastMonth = now.month == 1 ? DateTime(now.year - 1, 12, 1) : DateTime(now.year, now.month - 1, 1);
        range = DateTimeRange(
          start: lastMonth,
          end: DateTime(lastMonth.year, lastMonth.month + 1, 0),
        );
        break;
      case 'Custom':
        // For custom ranges, ensure the start date is before the end date.
        if (_startDate != null && _endDate != null && _startDate!.isBefore(_endDate!.add(const Duration(days: 1)))) {
          range = DateTimeRange(start: _startDate!, end: _endDate!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a valid start and end date')),
          );
          return;
        }
        break;
    }
    // Return the selected date range to the previous screen.
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
            // The month selection buttons.
            const Text('Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            _buildMonthSegment(),
            // The custom date range pickers, which are only shown when "Custom" is selected.
            if (_showCustom) ...[
              const SizedBox(height: 24),
              const Text('Date Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Row(
                children: [
                  // The start date picker.
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _startDate != null ? DateFormat('MMM d, yyyy').format(_startDate!) : 'Select Date',
                      ),
                      onTap: _selectStartDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // The end date picker.
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: _endDate != null ? DateFormat('MMM d, yyyy').format(_endDate!) : 'Select Date',
                      ),
                      onTap: _selectEndDate,
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            // The apply filters button.
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

  /// A helper method to build the segmented month buttons.
  Widget _buildMonthSegment() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMonthButton('All', _selectedMonth == 'All')),
            const SizedBox(width: 8),
            Expanded(child: _buildMonthButton('Current Month', _selectedMonth == 'Current Month')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildMonthButton('Last Month', _selectedMonth == 'Last Month')),
            const SizedBox(width: 8),
            Expanded(child: _buildMonthButton('Custom', _selectedMonth == 'Custom')),
          ],
        ),
      ],
    );
  }

  /// A helper method to build a single month button.
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
