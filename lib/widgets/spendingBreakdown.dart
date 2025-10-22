import 'package:expense_tracker/widgets/pie_chart.dart';
import 'package:flutter/material.dart';


// Helper: Build the spending breakdown card with pie chart
Widget buildSpendingBreakdown(double total, List<PieSegment> data) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Pie Chart Container
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [

                  // Custom Pie Chart using CustomPainter
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(
                      painter: PieChartPainter(data),
                    ),
                  ),
                  // Center Text (Total Spent again, as per design)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Spent',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '\$1,250',
                        style: TextStyle(
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
              // Legend: Rows of color dots and labels
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...data.map((segment) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: segment.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              segment.label,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
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

