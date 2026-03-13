import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class TimeSlotsList extends StatelessWidget {
  final Place place;
  final DateTime selectedDate;
  final int subPlaceIndex;
  final List<String> selectedSlots;
  final void Function(String slot, bool isBooked) onSlotTap;

  const TimeSlotsList({
    super.key,
    required this.place,
    required this.selectedDate,
    required this.subPlaceIndex,
    required this.selectedSlots,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayKey = DateFormat('EEEE dd/MM').format(selectedDate).toLowerCase();
    final sub = place.subPlaces[subPlaceIndex];

    final List<String> free = List.from(sub.freeTimeSlots[dayKey] ?? []);
    final List<String> booked = List.from(sub.bookedTimeSlots[dayKey] ?? []);
    final List<String> all = [...free, ...booked];

    all.sort((a, b) {
      final aBooked = booked.contains(a);
      final bBooked = booked.contains(b);
      if (aBooked != bBooked) return aBooked ? 1 : -1;
      return int.parse(a.split(':')[0]).compareTo(int.parse(b.split(':')[0]));
    });

    return ListView.builder(
      itemCount: all.length,
      itemBuilder: (context, i) {
        final s = all[i];
        final isB = booked.contains(s);
        final isS = selectedSlots.contains(s);

        return GestureDetector(
          onTap: () => onSlotTap(s, isB),
          child: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isS
                  ? ColorManager.egyptianEarth.withOpacity(0.2)
                  : ColorManager.wasabi.withOpacity(0.2),
              border: Border.all(
                color: isS ? ColorManager.wasabi : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(
                Icons.circle,
                color: isB ? Colors.red : ColorManager.wasabi,
                size: 12,
              ),
              title: Text(s, style: const TextStyle(color: Colors.white)),
              trailing: Text(
                isB ? "محجوز" : "متاح",
                style: TextStyle(color: isB ? Colors.red : ColorManager.wasabi),
              ),
            ),
          ),
        );
      },
    );
  }
}
