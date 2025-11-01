import 'package:expense_tracker/widgets/pie_chart.dart';
import 'package:flutter/material.dart';

/// A widget that displays a spending breakdown card with a pie chart and a legend.
///
/// This widget is used to visualize the distribution of expenses across different
/// categories. It takes the total amount spent and a list of [PieSegment] data
/// to render the pie chart and legend.
///
/// [total] The total amount of all expenses.
/// [data] A list of [PieSegment] data to be rendered in the pie chart.
///
/// Returns a [Card] widget containing the spending breakdown UI.
Widget buildSpendingBreakdown(double total, List<PieSegment> data) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              // A Stack is used to overlay the total spent text on top of the pie chart.
              Stack(
                alignment: Alignment.center,
                children: [
                  // The pie chart, which is rendered using a CustomPainter.
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(
                      painter: PieChartPainter(data),
                    ),
                  ),
                  // A white circle in the center of the pie chart to create a donut chart effect.
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // The total spent text, which is displayed in the center of the pie chart.
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Spent',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '\u20B9${total.toStringAsFixed(2)}', // The Indian Rupee symbol.
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // The legend for the pie chart, which displays the category and a colored dot for each segment.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map over the data to create a legend item for each segment.
                  ...data.map((segment) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            // A colored dot to represent the segment.
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: segment.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // The label for the segment.
                            Text(
                              segment.label,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      )),
                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}
