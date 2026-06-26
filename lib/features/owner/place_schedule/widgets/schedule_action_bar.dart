import 'dart:ui';
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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: _buildDecoration(),
          child: SafeArea(
            // تأمين الحواف في الموبايلات الحديثة
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: _buildSelectionInfo(context),
                ),
                const SizedBox(width: 12),
                _buildClearButton(context),
                const SizedBox(width: 8),
                _buildActionButton(context),
              ],
            ),
          ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (isSelectingBooked)
          Text(
            context.tr('cancellation_mode_active', defaultValue: 'Cancellation mode active'),
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        backgroundColor: isSelectingBooked ? Colors.redAccent : ColorManager.egyptianEarth,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        elevation: 0,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          isSelectingBooked 
              ? context.tr('cancel_bookings', defaultValue: 'Cancel Bookings') 
              : context.tr('manual_booking', defaultValue: 'Manual Booking'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: ColorManager.cardSurface.withOpacity(0.4),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      border: Border(
        top: BorderSide(
          color: ColorManager.emeraldGreen.withOpacity(0.3),
          width: 1.5,
        ),
      ),
    );
  }

  String _getSlotLabel(BuildContext context) => selectedCount == 1 
      ? context.tr('hour_selected_singular', defaultValue: 'hour selected') 
      : context.tr('hours_selected_plural', defaultValue: 'hours selected');
}
