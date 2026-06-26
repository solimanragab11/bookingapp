import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/features/user/booking/widgets/cross_line_painter.dart';

class SlotItemWidget extends StatelessWidget {
  final String slot;
  final String slotId;
  final bool isPast;
  final bool isBookedByOthers;
  final Map<String, dynamic> lockedSlots;
  final String? currentUserId;
  final bool isSelected;
  final VoidCallback onTap;
  final String Function(String) formatTimeSlot;

  const SlotItemWidget({
    super.key,
    required this.slot,
    required this.slotId,
    required this.isPast,
    required this.isBookedByOthers,
    required this.lockedSlots,
    required this.currentUserId,
    required this.isSelected,
    required this.onTap,
    required this.formatTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // 1. Check active locks in Firestore
    bool isLockedByYou = isSelected;
    bool isLockedByOthers = false;

    if (lockedSlots.containsKey(slotId)) {
      final lockInfo = Map<String, dynamic>.from(lockedSlots[slotId]);
      final expiresAt = lockInfo['expiresAt'] as Timestamp;
      final lockUserId = lockInfo['userId'] as String;

      if (expiresAt.toDate().isAfter(DateTime.now())) {
        if (lockUserId == currentUserId) {
          isLockedByYou = true;
        } else {
          isLockedByOthers = true;
        }
      }
    }

    // 2. Determine colors and styles based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor = Colors.white;
    FontWeight fontWeight = FontWeight.w500;
    bool hasCrossLine = false;
    String? subtitleKey;

    if (isBookedByOthers) {
      // Booked by other (already paid) - Grey with Cross Line
      backgroundColor = Colors.grey.withOpacity(0.2);
      borderColor = Colors.grey.withOpacity(0.3);
      textColor = Colors.white54;
      hasCrossLine = true;
    } else if (isPast) {
      // Past time - Red/disabled
      backgroundColor = Colors.red.withOpacity(0.4);
      borderColor = Colors.redAccent.withOpacity(0.5);
      fontWeight = FontWeight.bold;
    } else if (isLockedByOthers) {
      // Locked by another user (in process) - Warm Orange/Amber
      backgroundColor = Colors.orange.withOpacity(0.25);
      borderColor = Colors.orangeAccent;
      subtitleKey = 'in_process_other';
    } else if (isLockedByYou) {
      // Locked by current user - Purple
      backgroundColor = Colors.purple.shade400;
      borderColor = Colors.purpleAccent;
      fontWeight = FontWeight.bold;
      subtitleKey = 'in_process_yours';
    } else {
      // Free slot - Green
      backgroundColor = ColorManager.noirDeVigne.withOpacity(0.6);
      borderColor = ColorManager.emeraldGreen.withOpacity(0.35);
      textColor = ColorManager.creasedKhaki;
    }

    return GestureDetector(
      onTap: () {
        if (isBookedByOthers) {
          SnackBarUtils.showInfo(context, 'booked');
        } else if (isPast) {
          SnackBarUtils.showError(context, 'past');
        } else if (isLockedByOthers) {
          SnackBarUtils.showInfo(context, 'slot_busy_now');
        } else {
          onTap();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: (isLockedByYou || isLockedByOthers)
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  formatTimeSlot(slot),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: w * 0.032,
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
                if (subtitleKey != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.tr(subtitleKey),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: w * 0.022,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            if (hasCrossLine)
              Positioned.fill(
                child: CustomPaint(painter: CrossLinePainter()),
              ),
          ],
        ),
      ),
    );
  }
}
