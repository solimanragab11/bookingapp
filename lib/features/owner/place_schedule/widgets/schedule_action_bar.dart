import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/booking_summary_dialog.dart';

class ScheduleActionBar extends StatelessWidget {
  final Place place;
  final int selectedCount;
  final bool isSelectingBooked;
  final DateTime selectedDate;
  final int selectedSubPlaceIndex;
  final List<String> selectedSlots;
  final VoidCallback onClearSelection;

  const ScheduleActionBar({
    super.key,
    required this.place,
    required this.selectedCount,
    required this.isSelectingBooked,
    required this.selectedDate,
    required this.selectedSubPlaceIndex,
    required this.selectedSlots,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: ColorManager.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Row(
        children: [
          Text(
            "تم اختيار $selectedCount ساعة",
            style: const TextStyle(color: Colors.white),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => BookingSummaryDialog.show(
              context: context,
              place: place,
              selectedDate: selectedDate,
              selectedSubPlaceIndex: selectedSubPlaceIndex,
              selectedSlots: selectedSlots,
              isSelectingBooked: isSelectingBooked,
              onConfirmed: onClearSelection,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelectingBooked
                  ? Colors.red
                  : ColorManager.wasabi,
            ),
            child: Text(
              isSelectingBooked ? "إلغاء الحجوزات" : "تأكيد الحجز الجماعي",
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
