import 'package:flutter/material.dart';

class ScannerCornerBorders extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;
    double cornerSide = 12.0; // Fixed corner side length
    double borderLength =
        35.0; // Length of the straight border before corners (symmetric in both directions)

    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path()
      // Top-left corner
      ..moveTo(borderLength, 0)
      ..lineTo(cornerSide, 0)
      ..quadraticBezierTo(0, 0, 0, cornerSide)
      ..lineTo(0, borderLength)

      // Bottom-left corner
      ..moveTo(0, height - borderLength)
      ..lineTo(0, height - cornerSide)
      ..quadraticBezierTo(0, height, cornerSide, height)
      ..lineTo(borderLength, height)

      // Bottom-right corner
      ..moveTo(width - borderLength, height)
      ..lineTo(width - cornerSide, height)
      ..quadraticBezierTo(width, height, width, height - cornerSide)
      ..lineTo(width, height - borderLength)

      // Top-right corner
      ..moveTo(width, borderLength)
      ..lineTo(width, cornerSide)
      ..quadraticBezierTo(width, 0, width - cornerSide, 0)
      ..lineTo(width - borderLength, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ScannerCornerBorders oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(ScannerCornerBorders oldDelegate) => false;
}
