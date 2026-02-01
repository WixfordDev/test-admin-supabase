import 'dart:math';
import 'package:flutter/material.dart';

class IslamicPatternPainter extends CustomPainter {
  final Color patternColor;

  IslamicPatternPainter({required this.patternColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = patternColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw a subtle geometric pattern
    final int rows = 8;
    final int cols = 5;

    final double tileWidth = size.width / cols;
    final double tileHeight = size.height / rows;

    // Draw stars or geometric shapes
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final centerX = j * tileWidth + tileWidth / 2;
        final centerY = i * tileHeight + tileHeight / 2;

        if ((i + j) % 2 == 0) {
          // Draw octagonal star
          _drawOctagonalStar(canvas, paint, centerX, centerY, tileWidth * 0.3);
        } else {
          // Draw circle
          canvas.drawCircle(Offset(centerX, centerY), tileWidth * 0.1, paint);
        }
      }
    }
  }

  void _drawOctagonalStar(Canvas canvas, Paint paint, double centerX,
      double centerY, double radius) {
    final path = Path();

    for (int i = 0; i < 8; i++) {
      double angle = i * 45 * (3.14159 / 180);
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(IslamicPatternPainter oldDelegate) =>
      oldDelegate.patternColor != patternColor;
}
