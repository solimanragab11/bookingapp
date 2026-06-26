// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class CalendarStrip extends StatelessWidget {
  final SlotsModel? slots;
  final DateTime selectedDate;
  final int selectedSubPlaceIndex;
  final ValueChanged<DateTime> onDateSelected;

  const CalendarStrip({
    super.key,
    required this.slots,
    required this.selectedDate,
    required this.selectedSubPlaceIndex,
    required this.onDateSelected,
  });

  List<DateTime> _getAvailableDates() {
    if (slots == null) {
      // Default to next 14 days if slots are not loaded yet to prevent flashing
      return List.generate(14, (index) => DateTime.now().add(Duration(days: index)));
    }

    final Set<String> dayKeys = {};
    dayKeys.addAll(slots!.freeTimeSlots.keys);
    for (var booking in slots!.bookedTimeSlots) {
      dayKeys.addAll(booking.slots.keys);
    }

    if (dayKeys.isEmpty) {
      // If slots document exists but has no days, default to today
      return [DateTime.now()];
    }

    // Parse dayKeys into DateTimes
    final List<DateTime> dates = [];
    for (var dayKey in dayKeys) {
      final parsedDate = _parseDayKey(dayKey);
      dates.add(parsedDate);
    }

    // Sort dates chronologically
    dates.sort((a, b) => a.compareTo(b));
    return dates;
  }

  DateTime _parseDayKey(String dayKey) {
    try {
      final parts = dayKey.split(' ');
      if (parts.length < 2) return DateTime.now();

      final dateParts = parts[1].split('/');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);

      final now = DateTime.now();
      int year = now.year;
      if (month < now.month && now.month - month > 6) {
        year += 1;
      } else if (month > now.month && month - now.month > 6) {
        year -= 1;
      }

      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    // جلب كود اللغة الحالي (ar أو en)
    final String locale = Localizations.localeOf(context).languageCode;
    final dates = _getAvailableDates();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final date = dates[index];

          // dayKey بيفضل دايمًا بالإنجليزي مع التاريخ الكامل عشان يتطابق مع الـ Database
          String? matchedDayKey;
          if (slots != null) {
            final dayStr = DateFormat('dd/MM', 'en').format(date);
            for (var key in slots!.freeTimeSlots.keys) {
              if (key.endsWith(dayStr)) {
                matchedDayKey = key;
                break;
              }
            }
          }
          final dayKey = matchedDayKey ?? DateFormat('EEEE dd/MM', 'en').format(date).toLowerCase();

          final isFullyBooked = slots != null &&
              (slots!.freeTimeSlots[dayKey] == null ||
               slots!.freeTimeSlots[dayKey]!.isEmpty);

          final isSelected = DateUtils.isSameDay(date, selectedDate);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: isFullyBooked
                    ? Colors.redAccent.withOpacity(0.15)
                    : (isSelected
                        ? ColorManager.egyptianEarth
                        : ColorManager.cardSurface.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFullyBooked
                      ? Colors.redAccent.withOpacity(0.5)
                      : (isSelected
                          ? ColorManager.egyptianEarth
                          : ColorManager.emeraldGreen.withOpacity(0.2)),
                  width: 1.2,
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
                          : ColorManager.creasedKhaki,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
