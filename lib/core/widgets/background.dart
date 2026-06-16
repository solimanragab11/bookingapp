import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class BackGround extends StatelessWidget {
  const BackGround({
    super.key,
    required this.h,
    required this.w,
    this.category = 'all',
  });

  final double h;
  final double w;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Base Dark Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ColorManager.noirDeVigne, Color(0xFF0C1312)],
            ),
          ),
        ),

        // 2. Custom Painter for Tactical Sport Strategy Layout
        Positioned.fill(
          child: CustomPaint(
            painter: TacticalBackgroundPainter(
              category: category,
              lineColor: ColorManager.wasabi.withOpacity(0.08),
              accentColor: ColorManager.egyptianEarth.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }
}

class TacticalBackgroundPainter extends CustomPainter {
  final String category;
  final Color lineColor;
  final Color accentColor;

  TacticalBackgroundPainter({
    required this.category,
    required this.lineColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final arrowPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // 1. Draw a faint grid in the background
    double gridSpacing = 40.0;
    final gridPaint = Paint()
      ..color = lineColor.withOpacity(0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    switch (category.toLowerCase()) {
      case 'football':
        _paintFootball(canvas, size, linePaint, arrowPaint, fillPaint);
        break;
      case 'padel':
        _paintPadel(canvas, size, linePaint, arrowPaint, fillPaint);
        break;
      case 'playstation':
        _paintPlayStation(canvas, size, linePaint, arrowPaint, fillPaint);
        break;
      case 'cafe':
        _paintCafe(canvas, size, linePaint, arrowPaint, fillPaint);
        break;
      case 'all':
      default:
        _paintAll(canvas, size, linePaint, arrowPaint, fillPaint);
        break;
    }
  }

  void _paintFootball(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint arrowPaint,
    Paint fillPaint,
  ) {
    // Top-to-bottom tactical football field layout
    double pitchW = size.width - 40;
    double pitchH = size.height - 80;
    double startX = 20;
    double startY = 40;

    // Pitch borders
    canvas.drawRect(Rect.fromLTWH(startX, startY, pitchW, pitchH), linePaint);
    // Center line
    canvas.drawLine(
      Offset(startX, startY + pitchH / 2),
      Offset(startX + pitchW, startY + pitchH / 2),
      linePaint,
    );
    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, startY + pitchH / 2),
      60,
      linePaint,
    );

    // Penalty box (top)
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 80, startY, 160, 100),
      linePaint,
    );
    // Goal area (top)
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 40, startY, 80, 40),
      linePaint,
    );

    // Penalty box (bottom)
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 80, startY + pitchH - 100, 160, 100),
      linePaint,
    );
    // Goal area (bottom)
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 40, startY + pitchH - 40, 80, 40),
      linePaint,
    );

    // Strategy curves
    Path path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.65);
    path.quadraticBezierTo(
      size.width * 0.45,
      size.height * 0.55,
      size.width * 0.5,
      startY + pitchH - 110,
    );
    canvas.drawPath(path, arrowPaint);

    // Draw player marks
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.65),
      8,
      linePaint,
    );
    double xX = size.width * 0.5;
    double yX = startY + pitchH - 110;
    canvas.drawLine(Offset(xX - 6, yX - 6), Offset(xX + 6, yX + 6), arrowPaint);
    canvas.drawLine(Offset(xX + 6, yX - 6), Offset(xX - 6, yX + 6), arrowPaint);
  }

  void _paintPadel(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint arrowPaint,
    Paint fillPaint,
  ) {
    // Padel Court layout with net in the middle
    double courtW = size.width - 60;
    double courtH = size.height - 100;
    double startX = 30;
    double startY = 50;

    // Court boundaries
    canvas.drawRect(Rect.fromLTWH(startX, startY, courtW, courtH), linePaint);

    // Center Net Line
    final netPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(startX, startY + courtH / 2),
      Offset(startX + courtW, startY + courtH / 2),
      netPaint,
    );

    // Service lines (top & bottom)
    canvas.drawLine(
      Offset(startX, startY + courtH * 0.25),
      Offset(startX + courtW, startY + courtH * 0.25),
      linePaint,
    );
    canvas.drawLine(
      Offset(startX, startY + courtH * 0.75),
      Offset(startX + courtW, startY + courtH * 0.75),
      linePaint,
    );

    // Center service divider line
    canvas.drawLine(
      Offset(size.width / 2, startY + courtH * 0.25),
      Offset(size.width / 2, startY + courtH * 0.75),
      linePaint,
    );

    // Tactical lob shot strategy (high arc curve over the net)
    Path path = Path();
    path.moveTo(size.width * 0.35, startY + courtH * 0.85);
    path.quadraticBezierTo(
      size.width * 0.2,
      startY + courtH * 0.5,
      size.width * 0.45,
      startY + courtH * 0.15,
    );
    canvas.drawPath(path, arrowPaint);

    // Arrowhead
    Offset endPoint = Offset(size.width * 0.45, startY + courtH * 0.15);
    Path arrowHead = Path();
    arrowHead.moveTo(endPoint.dx, endPoint.dy);
    arrowHead.lineTo(endPoint.dx - 10, endPoint.dy + 8);
    arrowHead.lineTo(endPoint.dx + 2, endPoint.dy + 10);
    arrowHead.close();
    canvas.drawPath(arrowHead, fillPaint);
  }

  void _paintPlayStation(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint arrowPaint,
    Paint fillPaint,
  ) {
    // Playstation / gaming controller layout
    double dX = size.width * 0.25;
    double dY = size.height * 0.55;
    Path dpad = Path();
    dpad.moveTo(dX - 10, dY - 30);
    dpad.lineTo(dX + 10, dY - 30);
    dpad.lineTo(dX + 10, dY - 10);
    dpad.lineTo(dX + 30, dY - 10);
    dpad.lineTo(dX + 30, dY + 10);
    dpad.lineTo(dX + 10, dY + 10);
    dpad.lineTo(dX + 10, dY + 30);
    dpad.lineTo(dX - 10, dY + 30);
    dpad.lineTo(dX - 10, dY + 10);
    dpad.lineTo(dX - 30, dY + 10);
    dpad.lineTo(dX - 30, dY - 10);
    dpad.lineTo(dX - 10, dY - 10);
    dpad.close();
    canvas.drawPath(dpad, linePaint);

    // Action buttons on the right (△, ◯, ✕, ▢)
    double bX = size.width * 0.75;
    double bY = size.height * 0.55;

    // Draw Triangle (△)
    Path triangle = Path();
    triangle.moveTo(bX, bY - 35);
    triangle.lineTo(bX - 8, bY - 21);
    triangle.lineTo(bX + 8, bY - 21);
    triangle.close();
    canvas.drawPath(triangle, linePaint);

    // Draw Square (▢)
    canvas.drawRect(
      Rect.fromCenter(center: Offset(bX - 28, bY), width: 14, height: 14),
      linePaint,
    );
    // Draw Circle (◯)
    canvas.drawCircle(Offset(bX + 28, bY), 7, linePaint);
    // Draw Cross (✕)
    double cX = bX;
    double cY = bY + 28;
    canvas.drawLine(Offset(cX - 6, cY - 6), Offset(cX + 6, cY + 6), linePaint);
    canvas.drawLine(Offset(cX + 6, cY - 6), Offset(cX - 6, cY + 6), linePaint);

    // Connection path
    Path path = Path();
    path.moveTo(dX + 30, dY);
    path.lineTo(size.width / 2 - 20, dY);
    path.lineTo(size.width / 2, dY - 40);
    path.lineTo(bX - 40, dY - 40);
    canvas.drawPath(path, arrowPaint);
  }

  void _paintCafe(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint arrowPaint,
    Paint fillPaint,
  ) {
    // Cozy Cafe drawing (Abstract coffee cup and steam layout)
    double cupX = size.width * 0.5;
    double cupY = size.height * 0.55;

    // Cup rim/bowl
    Path cup = Path();
    cup.moveTo(cupX - 40, cupY - 20);
    cup.lineTo(cupX + 40, cupY - 20);
    cup.quadraticBezierTo(cupX + 35, cupY + 30, cupX, cupY + 30);
    cup.quadraticBezierTo(cupX - 35, cupY + 30, cupX - 40, cupY - 20);
    cup.close();
    canvas.drawPath(cup, linePaint);

    // Cup handle
    Path handle = Path();
    handle.moveTo(cupX + 38, cupY - 10);
    handle.cubicTo(
      cupX + 60,
      cupY - 15,
      cupX + 60,
      cupY + 15,
      cupX + 32,
      cupY + 15,
    );
    canvas.drawPath(handle, linePaint);

    // Plate/Saucer
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cupX, cupY + 35), width: 110, height: 16),
      linePaint,
    );

    // Floating Steam curves
    Path steam1 = Path();
    steam1.moveTo(cupX - 15, cupY - 30);
    steam1.cubicTo(
      cupX - 25,
      cupY - 60,
      cupX - 5,
      cupY - 80,
      cupX - 15,
      cupY - 110,
    );
    canvas.drawPath(steam1, arrowPaint);

    Path steam2 = Path();
    steam2.moveTo(cupX + 10, cupY - 30);
    steam2.cubicTo(
      cupX,
      cupY - 60,
      cupX + 20,
      cupY - 80,
      cupX + 10,
      cupY - 110,
    );
    canvas.drawPath(steam2, arrowPaint);
  }

  void _paintAll(
    Canvas canvas,
    Size size,
    Paint linePaint,
    Paint arrowPaint,
    Paint fillPaint,
  ) {
    // Generic tactical board drawing (the original layout)
    double pitchW = size.width * 0.7;
    double pitchH = size.height * 0.35;
    double startX = size.width * 0.35;
    double startY = -size.height * 0.05;

    canvas.drawRect(Rect.fromLTWH(startX, startY, pitchW, pitchH), linePaint);
    canvas.drawCircle(Offset(startX, startY + pitchH), 40, linePaint);

    // Penalty box
    canvas.drawRect(
      Rect.fromLTWH(startX + pitchW * 0.2, startY, pitchW * 0.6, pitchH * 0.4),
      linePaint,
    );

    // Diagonal speed accents
    final speedPaint = Paint()
      ..color = lineColor.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      double dY = size.height * 0.45 + (i * 80);
      canvas.drawLine(
        Offset(-20, dY),
        Offset(size.width + 20, dY + 120),
        speedPaint,
      );
    }

    // Small tactical arrow
    Path path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.42,
      size.width * 0.45,
      size.height * 0.5,
    );
    canvas.drawPath(path, arrowPaint);

    Offset end = Offset(size.width * 0.45, size.height * 0.5);
    Path arrowHead = Path();
    arrowHead.moveTo(end.dx, end.dy);
    arrowHead.lineTo(end.dx - 12, end.dy - 2);
    arrowHead.lineTo(end.dx - 8, end.dy + 8);
    arrowHead.close();
    canvas.drawPath(arrowHead, fillPaint);
  }

  @override
  bool shouldRepaint(covariant TacticalBackgroundPainter oldDelegate) {
    return oldDelegate.category != category ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}
