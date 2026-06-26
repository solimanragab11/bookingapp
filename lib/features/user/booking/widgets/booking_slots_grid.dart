// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/features/user/booking/widgets/slot_item_widget.dart';

class BookingSlotsGrid extends StatelessWidget {
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
  final Map<String, dynamic> lockedSlots;
  final String? currentUserId;
  final Function(String slotId) onSlotToggled;
  final String Function(String) formatTimeSlot;

  BookingSlotsGrid({
    super.key,
    required this.selectedDay,
    required this.selectedBookingSlots,
    required this.onSlotToggled,
    required this.formatTimeSlot,
    required this.freeTimeSlots,
    required this.lockedSlots,
    required this.currentUserId,
    required List<BookingIdModel> bookedTimeSlots,
  });

  @override
  Widget build(BuildContext context) {
    // Exact list of 24 hours slots
    final List<String> exactSlots = [
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

    final now = DateTime.now();

    final daySlots = freeTimeSlots[selectedDay];
    final bool hasNoSlots = daySlots == null || daySlots.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: ColorManager.emeraldGreen.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: hasNoSlots
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white24,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('noSlotsAvailable'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exactSlots.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.8, // Slightly adjusted ratio to fit time and status subtitle nicely
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final slot = exactSlots[index];
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

                return SlotItemWidget(
                  slot: slot,
                  slotId: slotId,
                  isPast: isPast,
                  isBookedByOthers: isBookedByOthers,
                  lockedSlots: lockedSlots,
                  currentUserId: currentUserId,
                  isSelected: isSelected,
                  onTap: () => onSlotToggled(slotId),
                  formatTimeSlot: formatTimeSlot,
                );
              },
            ),
    );
  }
}
