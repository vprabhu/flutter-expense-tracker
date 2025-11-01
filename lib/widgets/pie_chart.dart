import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A data model class that represents a single segment of a pie chart.
class PieSegment {
  /// The label for the segment, which is displayed in the legend.
  final String label;

  /// The value of the segment, which determines its size in the pie chart.
  final double amount;

  /// The color of the segment.
  final Color color;

  /// Creates an instance of the [PieSegment] class.
  PieSegment({required this.label, required this.amount, required this.color});
}

/// A custom painter that renders a pie chart from a list of [PieSegment] data.
class PieChartPainter extends CustomPainter {
  /// The data to be rendered in the pie chart.
  final List<PieSegment> data;

  /// Creates an instance of the [PieChartPainter] class.
  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // The center of the pie chart.
    final center = Offset(size.width / 2, size.height / 2);
    // The radius of the pie chart.
    final radius = math.min(size.width / 2, size.height / 2) - 10;
    // The starting angle for the first segment.
    double startAngle = -math.pi / 2; // Start from the top.

    // Calculate the total amount of all segments to determine the percentage of each segment.
    final total = data.fold<double>(0, (sum, segment) => sum + segment.amount);

    // Iterate over the data and draw each segment of the pie chart.
    for (final segment in data) {
      // Calculate the sweep angle for the current segment.
      final sweepAngle = (segment.amount / total) * 2 * math.pi;
      // Create a paint object with the color of the segment.
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      // Draw the arc for the current segment.
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Update the starting angle for the next segment.
      startAngle += sweepAngle;
    }
  }

  // This method determines whether the pie chart should be repainted.
  // In this case, we return false because the pie chart is static and does not need to be repainted.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
