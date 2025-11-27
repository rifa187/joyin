import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

// --- DATA MODELS ---
class PieChartData {
  final String label;
  final double value;
  final Color color;
  const PieChartData(this.label, this.value, this.color);
}

// --- PAINTER UNTUK GRAFIK BATANG ---
class ChartGridPainter extends CustomPainter {
  final double maxValue;
  final double averageValue;
  final double labelSpace;
  final int horizontalDividers;
  final double leftPadding;

  const ChartGridPainter({
    required this.maxValue,
    required this.averageValue,
    required this.labelSpace,
    this.horizontalDividers = 3,
    this.leftPadding = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double chartHeight = size.height - labelSpace;
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE6F2EC)
      ..strokeWidth = 1;

    for (int i = 0; i <= horizontalDividers; i++) {
      final double y = (chartHeight / horizontalDividers) * i;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);

      final textSpan = TextSpan(
        text: (maxValue / horizontalDividers * (horizontalDividers - i)).toStringAsFixed(0),
        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8A97A1)),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding - textPainter.width - 8, y - textPainter.height / 2));
    }

    final double avgY = chartHeight - (averageValue / maxValue * chartHeight);
    final Paint averagePaint = Paint()
      ..color = const Color(0xFF5AC0AA)
      ..strokeWidth = 1.2;

    double dashX = 0;
    const double dashWidth = 6;
    const double dashSpace = 4;
    while (dashX < size.width) {
      final double endX = (dashX + dashWidth).clamp(0, size.width);
      canvas.drawLine(Offset(dashX, avgY), Offset(endX, avgY), averagePaint);
      dashX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PAINTER UNTUK PIE CHART ---
class PieChartPainter extends CustomPainter {
  final List<PieChartData> data;
  final double strokeWidth;

  PieChartPainter({required this.data, this.strokeWidth = 24});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;
    double startAngle = -math.pi / 2;

    for (final slice in data) {
      final sweepAngle = (slice.value / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle - 0.03,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}