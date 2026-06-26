import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingTimeHelper {
  // 1. حساب وقت بداية الحجز (أقدم وقت في المصفوفة)
  static DateTime? getBookingStartTime(Map<String, dynamic> booking) {
    try {
      final String fullDay = booking['timeSlots']?.keys?.first ?? "";
      final List<dynamic> slots = booking['timeSlots']?.values?.first ?? [];
      if (fullDay.isEmpty || slots.isEmpty) return null;

      final datePart = fullDay.contains(' ') ? fullDay.split(' ').last : "";
      if (datePart.isEmpty) return null;

      int year = _extractYear(booking);

      DateTime? earliestStart;
      for (var slot in slots) {
        final String rawTimeRange = slot.toString();
        // بناخد الجزء الأول من الوقت (قبل علامة -)
        final String timePart = rawTimeRange.contains('-')
            ? rawTimeRange.split('-').first.trim()
            : rawTimeRange.trim();

        final parsed = _parseSlotTime(datePart, timePart, year);
        if (parsed != null) {
          if (earliestStart == null || parsed.isBefore(earliestStart)) {
            earliestStart = parsed; // لو لقينا وقت أقدم، بنحفظه
          }
        }
      }
      return earliestStart;
    } catch (e) {
      debugPrint("Error parsing booking start time: $e");
      return null;
    }
  }

  // 2. حساب وقت نهاية الحجز (أحدث وقت في المصفوفة)
  static DateTime? getBookingEndTime(Map<String, dynamic> booking) {
    try {
      final String fullDay = booking['timeSlots']?.keys?.first ?? "";
      final List<dynamic> slots = booking['timeSlots']?.values?.first ?? [];
      if (fullDay.isEmpty || slots.isEmpty) return null;

      final datePart = fullDay.contains(' ') ? fullDay.split(' ').last : "";
      if (datePart.isEmpty) return null;

      int year = _extractYear(booking);

      DateTime? latestEnd;
      for (var slot in slots) {
        final String rawTimeRange = slot.toString();
        DateTime? parsedEnd;

        // بناخد الجزء التاني من الوقت (بعد علامة -)
        if (rawTimeRange.contains('-')) {
          final timePart = rawTimeRange.split('-').last.trim();
          parsedEnd = _parseSlotTime(datePart, timePart, year);
        } else {
          final timePart = rawTimeRange.trim();
          final start = _parseSlotTime(datePart, timePart, year);
          parsedEnd = start?.add(
            const Duration(hours: 1),
          ); // افتراضي ساعة لو مفيش نهاية
        }

        if (parsedEnd != null) {
          if (latestEnd == null || parsedEnd.isAfter(latestEnd)) {
            latestEnd = parsedEnd; // لو لقينا وقت أحدث، بنحفظه
          }
        }
      }
      return latestEnd;
    } catch (e) {
      debugPrint("Error parsing booking end time: $e");
      return null;
    }
  }

  // 3. دالة مساعدة: استخراج السنة من تاريخ الإنشاء
  static int _extractYear(Map<String, dynamic> booking) {
    int year = DateTime.now().year;
    if (booking['createdAt'] != null) {
      final dynamic createdAtData = booking['createdAt'];
      if (createdAtData is DateTime) {
        year = createdAtData.year;
      } else if (createdAtData is Timestamp) {
        year = createdAtData.toDate().year;
      }
    }
    return year;
  }

  // 4. دالة مساعدة: تحويل النص لتاريخ ووقت (مع مراعاة الساعة 24:00)
  static DateTime? _parseSlotTime(
    String datePart,
    String timePart,
    int baseYear,
  ) {
    try {
      final dateComps = datePart.split('/');
      final timeComps = timePart.split(':');
      if (dateComps.length < 2 || timeComps.isEmpty) return null;

      final int day = int.parse(dateComps[0]);
      final int month = int.parse(dateComps[1]);
      int year = baseYear;
      if (dateComps.length >= 3) {
        year = int.parse(dateComps[2]);
      }

      int hour = int.parse(timeComps[0]);
      final int minute = timeComps.length > 1
          ? int.parse(timeComps[1].trim())
          : 0;

      int dayOffset = 0;
      if (hour >= 24) {
        dayOffset = hour ~/ 24;
        hour = hour % 24;
      }

      final parsed = DateTime(year, month, day, hour, minute);
      if (dayOffset > 0) {
        return parsed.add(Duration(days: dayOffset));
      }
      return parsed;
    } catch (e) {
      debugPrint("Error parsing slot components: $e");
      return null;
    }
  }

  // 5. هل مسموح للموظف يضغط (لم يحضر)؟
  static bool isNoShowActionAllowed(Map<String, dynamic> booking) {
    final start = getBookingStartTime(booking);
    final end = getBookingEndTime(booking);

    if (start == null || end == null) {
      debugPrint(
        "[BookingTimeHelper] isNoShowActionAllowed: start or end is null. Allowed=false",
      );
      return false;
    }

    final duration = end.difference(start);
    final halfDuration = duration ~/ 2;
    final halfTime = start.add(halfDuration); // وقت السماح هو نص وقت الماتش
    final now = DateTime.now();

    final allowed = now.isAfter(halfTime);
    debugPrint(
      "[BookingTimeHelper] isNoShowActionAllowed: start=$start, end=$end, duration=$duration, halfTime=$halfTime, now=$now, allowed=$allowed",
    );
    return allowed;
  }
}
