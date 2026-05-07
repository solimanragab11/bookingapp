// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_id_model.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/cross_line_painter.dart';

class BookingSlotsGrid extends StatelessWidget {
  // نصوص الرسائل والـ Status
  static const String msgAlreadyBooked = "عذssراً، هذا الموعد محجوز مسبقاً";
  static const String msgTimeStarted = "هذا الموعssد قد بدأ بالفعل";

  final List<String> slots = [
    "0:00 - 1:00",
    "1:00 - 2:00",
    "2:00 - 3:00",
    "3:00 - 4:00",
    "4:00 - 5:00",
    "5:00 - 6:00",
    "6:00 - 7:00",
    "7:00 - 8:00",
    "8:00 - 9:00",
    "9:00 - 10:00",
    "10:00 - 11:00",
    "11:00 - 12:00",
    "12:00 - 13:00",
    "13:00 - 14:00",
    "14:00 - 15:00",
    "15:00 - 16:00",
    "16:00 - 17:00",
    "17:00 - 18:00",
    "18:00 - 19:00",
    "19:00 - 20:00",
    "20:00 - 21:00",
    "21:00 - 22:00",
    "22:00 - 23:00",
    "23:00 - 24:00",
  ];

  final String selectedDay;
  final Set<String> selectedBookingSlots;
  final Map<String, List<String>> freeTimeSlots;
  final Function(String slotId) onSlotToggled;
  final String Function(String) formatTimeSlot;

  BookingSlotsGrid({
    super.key,
    required this.selectedDay,
    required this.selectedBookingSlots,
    required this.onSlotToggled,
    required this.formatTimeSlot,
    required this.freeTimeSlots,
    required List<BookingIdModel> bookedTimeSlots,
  });

  void _showStatusMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: ColorManager.creasedKhaki.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: slots.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final slot = slots[index];
          final slotId = '${selectedDay}_$slot';

          bool isPast = false;
          try {
            final selectedParts = selectedDay.split(' ').last.split('/');
            final sDay = int.parse(selectedParts[0]);
            final sMonth = int.parse(selectedParts[1]);
            final startHour = int.parse(
              slot.split(' - ').first.split(':').first,
            );

            if (sDay == now.day && sMonth == now.month) {
              if (now.hour >= startHour) isPast = true;
            }
          } catch (_) {}

          final isFree = freeTimeSlots[selectedDay]?.contains(slot) ?? false;
          final isSelected = selectedBookingSlots.contains(slotId);
          final isBookedByOthers = !isFree && !isPast;

          return GestureDetector(
            onTap: () {
              if (isBookedByOthers) {
                _showStatusMessage(
                  context,
                  context.tr('booked'),
                  Colors.grey[800]!,
                );
              } else {
                if (isPast) {
                  _showStatusMessage(
                    context,
                    context.tr('past'),
                    Colors.redAccent,
                  );
                } else {
                  onSlotToggled(slotId);
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isBookedByOthers
                    ? Colors.grey.withOpacity(0.2)
                    : (isPast
                          ? Colors.red.withOpacity(0.4)
                          : (isSelected
                                ? ColorManager.wasabi
                                : ColorManager.noirDeVigne.withOpacity(0.6))),
                border: Border.all(
                  color: isPast
                      ? Colors.redAccent
                      : (isSelected
                            ? ColorManager.wasabi
                            : ColorManager.creasedKhaki.withOpacity(0.2)),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    formatTimeSlot(slot),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: w * 0.032,
                      color: (isPast || isBookedByOthers)
                          ? Colors.white
                          : (isSelected
                                ? ColorManager.noirDeVigne
                                : ColorManager.creasedKhaki),
                      fontWeight: (isPast || isSelected)
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  if (isBookedByOthers)
                    Positioned.fill(
                      child: CustomPaint(painter: CrossLinePainter()),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
