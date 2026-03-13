import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';

class CustButton extends StatefulWidget {
  const CustButton({
    super.key,
    required this.h,
    required this.w,
    required this.color,
    required this.onTap,
    required this.size,
    required this.lable,
  });

  final double h;
  final double w;
  final Color color;
  final VoidCallback onTap;
  final String size;
  final String lable;

  @override
  State<CustButton> createState() => _CustButtonState();
}

class _CustButtonState extends State<CustButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0; // ده اللي هيتحكم في حجم الزرار

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.92); // بيصغر لـ 92% من حجمه لما تلمسه
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0); // يرجع لحجمه الطبيعي
  }

  @override
  Widget build(BuildContext context) {
    // تحديد الأبعاد (نفس المنطق بتاعك)
    double buttonHeight = widget.size == "big"
        ? widget.h * 0.08
        : (widget.size == "mid" ? widget.h * 0.065 : widget.h * 0.05);

    double buttonWidth = widget.size == "big"
        ? widget.w * 0.9
        : (widget.size == "mid" ? widget.w * 0.6 : widget.w * 0.4);

    double fontSize = widget.size == "big"
        ? widget.w * 0.05
        : (widget.size == "mid" ? widget.w * 0.045 : widget.w * 0.035);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          // الودجت السحرية للأنيميشن
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(widget.w * 0.04),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.3),
                  blurRadius: _scale == 1.0
                      ? 12
                      : 4, // الضل بيقل لما الزرار يتضغط
                  offset: _scale == 1.0
                      ? const Offset(0, 6)
                      : const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.lable,
                style: TextStyleMangare.headingStyle.copyWith(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
