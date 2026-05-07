// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class CalendarStrip extends StatelessWidget {
  final PlaceModel place;
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
    // جلب كود اللغة الحالي (ar أو en)
    final String locale = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));

          // dayKey بيفضل دايمًا بالإنجليزي لأنه مفتاح في الـ Map عندك (Database Logic)
          final dayKey = DateFormat('EEEE', 'en').format(date).toLowerCase();

          final subPlace = place.subPlaces[selectedSubPlaceIndex];
          final isFullyBooked =
              (subPlace.freeTimeSlots[dayKey]?.isEmpty) ?? false;

          final isSelected = DateUtils.isSameDay(date, selectedDate);

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
                          : ColorManager.wasabi.withOpacity(
                              0.2,
                            )), // تعديل بسيط للشفافية عشان تبرز أكتر
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
                    // عرض اسم اليوم مختصر (E) مترجم أوتوماتيكياً (السبت، Sat، إلخ)
                    DateFormat('E', locale).format(date),
                    style: TextStyle(
                      color: isSelected || isFullyBooked
                          ? Colors.white
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    // الأرقام بتتحول أوتوماتيك لشكلها في اللغة (١، ٢، ٣ أو 1, 2, 3)
                    DateFormat.d(locale).format(date),
                    style: TextStyle(
                      color: Colors.white,
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
