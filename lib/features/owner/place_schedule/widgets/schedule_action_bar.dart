import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class ScheduleActionBar extends StatelessWidget {
  final int selectedCount;
  final bool isSelectingBooked;
  final VoidCallback onClearSelection;
  final VoidCallback onActionPressed; // هنا خلينا الـ UI يقرر يفتح إيه

  const ScheduleActionBar({
    super.key,
    required this.selectedCount,
    required this.isSelectingBooked,
    required this.onClearSelection,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: _buildDecoration(),
      child: SafeArea(
        // تأمين الحواف في الموبايلات الحديثة
        top: false,
        child: Row(
          children: [
            _buildSelectionInfo(),
            const Spacer(),
            _buildClearButton(),
            const SizedBox(width: 8),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets (فصل المكونات الصغيرة للقراءة) ---

  Widget _buildSelectionInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$selectedCount ${_getSlotLabel()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (isSelectingBooked)
          const Text(
            'وضع الإلغاء نشط',
            style: TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      onPressed: onClearSelection,
      icon: const Icon(Icons.close, color: Colors.white54),
      tooltip: 'إلغاء التحديد',
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton(
      onPressed: onActionPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelectingBooked ? Colors.red : ColorManager.wasabi,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        isSelectingBooked ? 'إلغاء الحجوزات' : 'حجز يدوي',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return const BoxDecoration(
      color: ColorManager.cardSurface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
    );
  }

  String _getSlotLabel() => selectedCount == 1 ? 'ساعة محددة' : 'ساعات محددة';
}
