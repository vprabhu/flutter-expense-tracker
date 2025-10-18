import 'package:flutter/material.dart';
import 'dart:math' as math;

// Data Model: PieSegment for chart data
class PieSegment {
  final String label;
  final double amount;
  final Color color;

  PieSegment({required this.label, required this.amount, required this.color});
}

// CustomPainter: For rendering the pie chart
class PieChartPainter extends CustomPainter {
  final List<PieSegment> data;

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 10;
    double startAngle = -math.pi / 2; // Start from top

    // Calculate total for percentages
    final total = data.fold<double>(0, (sum, segment) => sum + segment.amount);

    for (final segment in data) {
      final sweepAngle = (segment.amount / total) * 2 * math.pi;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
