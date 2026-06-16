import 'dart:ui';
import 'package:flutter/material.dart';

class RocketArrowUploadOverlay extends StatelessWidget {
  final double progress; // النسبة المئوية من الـ Cubit (من 0.0 لـ 100.0)

  const RocketArrowUploadOverlay({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    // لو الرفع لسة مبدأش أو خلص خلاص، نقفل الـ Overlay
    if (progress <= 0 || progress >= 100) return const SizedBox.shrink();

    final double screenHeight = MediaQuery.of(context).size.height;
    final Color themeColor = const Color(0xFFB36334); // درجة البني الخاصة بك

    // تحويل النسبة لقيمة بين 0.0 و 1.0
    final double progressFraction = (progress / 100).clamp(0.0, 1.0);

    // حساب بداية انطلاق الصاروخ من القاع حتى يختفي تماماً من الأعلى عند 100%
    final double startPosition = -180.0; // تحت الشاشة بقليل
    final double endPosition = screenHeight + 50; // يعبر الشاشة لأعلى تماماً

    // الموقع الحالي للسهم الصاروخي بناءً على النسبة
    final double currentBottomPosition =
        startPosition + (progressFraction * (endPosition - startPosition));

    return Stack(
      children: [
        // 1. خلفية مموهة ومظلمة بشكل سينمائي شيك
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
        ),

        // 2. سيل الدخان والـ Fire Trail المتوهج اللي بيلحق الصاروخ من أسفل الشاشة
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          // الدخان بيكبر في الارتفاع ليلحق بمكان الصاروخ الحالي
          height: (currentBottomPosition + 150).clamp(0.0, screenHeight),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  themeColor.withOpacity(0.5), // توهج ناري تحت الصاروخ مباشرة
                  Colors.orange.withOpacity(0.2),
                  Colors.white.withOpacity(0.05), // دخان يتلاشى في القاع
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // 3. 🚀 السهم الصاروخي المنطلق لأعلى ديناميكياً
        AnimatedPositioned(
          duration: const Duration(
            milliseconds: 200,
          ), // أنميشن سلس جداً مع تحديث الشبكة
          curve: Curves.easeOutCubic,
          bottom: currentBottomPosition,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // نص النسبة المئوية طائر فوق الصاروخ مباشرة
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: themeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    "${progress.toStringAsFixed(0)}% Uploading...",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ويدجيت السهم المرسوم هندسياً
                SizedBox(
                  width: 120,
                  height: 150,
                  child: CustomPaint(
                    painter: RocketArrowPainter(color: themeColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 🎨 رسمة السهم الهندسية (الصاروخ) لتطابق الهوية البصرية للتطبيق
class RocketArrowPainter extends CustomPainter {
  final Color color;
  RocketArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    double shaftWidth = size.width * 0.35; // عرض جسم الصاروخ
    double headHeight = size.height * 0.35; // ارتفاع رأس السهم المثلث

    // رسم المثلث العلوي (رأس السهم)
    path.moveTo(size.width / 2, 0); // سن الصاروخ
    path.lineTo(size.width, headHeight); // الجناح الأيمن
    path.lineTo(
      size.width / 2 + shaftWidth / 2,
      headHeight,
    ); // الدخول لداخل نقطة التقاء الجسم

    // رسم الجسم (العمود النازل)
    path.lineTo(
      size.width / 2 + shaftWidth / 2,
      size.height,
    ); // النزول للقاع يميناً
    path.lineTo(
      size.width / 2 - shaftWidth / 2,
      size.height,
    ); // التحرك لليسار في القاع
    path.lineTo(
      size.width / 2 - shaftWidth / 2,
      headHeight,
    ); // الصعود لأول الجسم يساراً

    path.lineTo(0, headHeight); // الجناح الأيسر الخارجي
    path.close();

    // إضافة تأثير ظل خارجي خفيف لإعطاء مجسم للصاروخ فوق التمويه
    canvas.drawShadow(path, Colors.black, 6.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RocketArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
