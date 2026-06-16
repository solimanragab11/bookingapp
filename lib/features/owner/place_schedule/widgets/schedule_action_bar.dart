import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

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
            _buildSelectionInfo(context),
            const Spacer(),
            _buildClearButton(context),
            const SizedBox(width: 8),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets (فصل المكونات الصغيرة للقراءة) ---

  Widget _buildSelectionInfo(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$selectedCount ${_getSlotLabel(context)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        if (isSelectingBooked)
          Text(
            context.tr('cancellation_mode_active', defaultValue: 'Cancellation mode active'),
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
      ],
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return IconButton(
      onPressed: onClearSelection,
      icon: const Icon(Icons.close, color: Colors.white54),
      tooltip: context.tr('clear_selection', defaultValue: 'Clear selection'),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onActionPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelectingBooked ? Colors.red : ColorManager.wasabi,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        isSelectingBooked 
            ? context.tr('cancel_bookings', defaultValue: 'Cancel Bookings') 
            : context.tr('manual_booking', defaultValue: 'Manual Booking'),
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

  String _getSlotLabel(BuildContext context) => selectedCount == 1 
      ? context.tr('hour_selected_singular', defaultValue: 'hour selected') 
      : context.tr('hours_selected_plural', defaultValue: 'hours selected');
}
