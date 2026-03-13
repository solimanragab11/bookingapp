import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class CalendarStrip extends StatelessWidget {
  final Place place;
  final DateTime selectedDate;
  final int selectedSubPlaceIndex;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarStrip({
    super.key,
    required this.place,
    required this.selectedDate,
    required this.selectedSubPlaceIndex,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final dayKey = DateFormat('EEEE').format(date).toLowerCase();

          final subPlace = place.subPlaces[selectedSubPlaceIndex];
          final isFullyBooked =
              (subPlace.freeTimeSlots[dayKey]?.isEmpty) ?? false;

          final isSelected =
              date.day == selectedDate.day && date.month == selectedDate.month;

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: isFullyBooked
                    ? Colors.red.withOpacity(0.3)
                    : (isSelected
                          ? ColorManager.egyptianEarth
                          : ColorManager.wasabi),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isFullyBooked
                      ? Colors.red
                      : (isSelected ? Colors.white24 : Colors.transparent),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected || isFullyBooked
                          ? Colors.white
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected || isFullyBooked
                          ? Colors.white
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
