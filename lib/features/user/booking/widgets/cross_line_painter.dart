import 'package:flutter/material.dart';

class CrossLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors
          .white24 // لون الخط المائل
      ..strokeWidth = 1.5;

    // خط من فوق شمال لتحت يمين
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    // خط من فوق يمين لتحت شمال
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
