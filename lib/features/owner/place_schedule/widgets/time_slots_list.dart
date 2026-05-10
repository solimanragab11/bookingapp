// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_id_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';

class TimeSlotsList extends StatelessWidget {
  final PlaceModel place;
  final DateTime selectedDate;
  final int subPlaceIndex;
  final List<String> selectedSlots;
  // أضفنا الـ bookingId المختار حالياً لمنع التداخل
  final String? activeBookingId;
  final void Function(String slot, bool isBooked, BookingIdModel? booking)
  onSlotTap;

  const TimeSlotsList({
    super.key,
    required this.place,
    required this.selectedDate,
    required this.subPlaceIndex,
    required this.selectedSlots,
    this.activeBookingId,
    required this.onSlotTap,
  });

  String _formatToLocal12Hour(BuildContext context, String slot) {
    try {
      final timePart = slot.split(' - ').first;
      final hour = int.parse(timePart.split(':').first);
      final minute = int.parse(timePart.split(':').last);
      final dateTime = DateTime(0, 0, 0, hour, minute);
      return DateFormat.jm(
        Localizations.localeOf(context).languageCode,
      ).format(dateTime);
    } catch (e) {
      return slot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayKey = DateFormat('EEEE dd/MM').format(selectedDate).toLowerCase();
    final sub = place.subPlaces[subPlaceIndex];

    final List<String> free = List.from(sub.freeTimeSlots[dayKey] ?? []);
    final List<String> booked = sub.bookedTimeSlots
        .expand((booking) => booking.slots[dayKey] ?? <String>[])
        .toList();

    final List<String> all = [...free, ...booked];

    bool checkIsPast(String slot) {
      final isToday = DateUtils.isSameDay(selectedDate, now);
      if (selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
        return true;
      }
      if (isToday) {
        try {
          final startHour = int.parse(slot.split(':').first);
          if (now.hour >= startHour) return true;
        } catch (_) {}
      }
      return false;
    }

    all.sort((a, b) {
      final aPast = checkIsPast(a);
      final bPast = checkIsPast(b);
      final aUnav = aPast || booked.contains(a);
      final bUnav = bPast || booked.contains(b);
      if (aUnav != bUnav) return aUnav ? 1 : -1;
      return int.parse(a.split(':')[0]).compareTo(int.parse(b.split(':')[0]));
    });

    return ListView.builder(
      itemCount: all.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, i) {
        final slot = all[i];
        final isPast = checkIsPast(slot);
        final isSelected = selectedSlots.contains(slot);

        // جلب بيانات الحجز للساعة الحالية
        final bookingDetails = sub.bookedTimeSlots.firstWhere(
          (b) => b.slots[dayKey]?.contains(slot) ?? false,
          orElse: () => BookingIdModel(
            bookingId: '',
            bookedBy: '',
            bookername: '',
            slots: {},
          ),
        );

        final bool isBookedByOthers = bookingDetails.bookingId.isNotEmpty;
        final bool isBookedByOwner = bookingDetails.bookedBy == 'owner';
        final bool isBookedByUser = isBookedByOthers && !isBookedByOwner;

        // التحقق من "وحدة الحجز": هل هذه الساعة تنتمي لنفس الحجز المختار حالياً؟
        bool isFromDifferentBooking = false;
        if (selectedSlots.isNotEmpty && isBookedByOthers) {
          if (activeBookingId != null &&
              activeBookingId != bookingDetails.bookingId) {
            isFromDifferentBooking = true;
          }
        }

        String statusText;
        Color bgColor;
        Color contentColor;
        IconData leadingIcon = Icons.access_time_filled;

        if (isPast) {
          statusText = context.tr('past_status');
          bgColor = Colors.red.withOpacity(0.4);
          contentColor = Colors.white;
        } else if (isBookedByUser) {
          statusText = context.tr('booked_by_app');
          bgColor = Colors.grey.withOpacity(0.2);
          contentColor = Colors.grey;
          leadingIcon = Icons.lock;
        } else if (isBookedByOwner) {
          // عرض اسم ورقم المحجوز له في الـ statusText
          statusText =
              "${bookingDetails.bookedBy}\n${bookingDetails.bookername}";
          bgColor = isFromDifferentBooking
              ? Colors.orange.withOpacity(0.05)
              : Colors.orange.withOpacity(0.2);
          contentColor = isFromDifferentBooking
              ? Colors.orange.withOpacity(0.3)
              : Colors.orange;
        } else if (isSelected) {
          statusText = context.tr('booked_by_you');
          bgColor = ColorManager.wasabi;
          contentColor = Colors.black;
          leadingIcon = Icons.check_circle;
        } else {
          statusText = context.tr('available_status');
          bgColor = ColorManager.wasabi.withOpacity(0.1);
          contentColor = ColorManager.wasabi;
        }

        return Opacity(
          opacity: (isBookedByUser || isFromDifferentBooking) ? 0.5 : 1.0,
          child: GestureDetector(
            onTap: () {
              if (isPast) {
                _showStatusMessage(
                  context,
                  context.tr('msg_time_started'),
                  Colors.redAccent,
                );
              } else if (isBookedByUser) {
                _showStatusMessage(
                  context,
                  context.tr('msg_user_booking_protected'),
                  Colors.blueGrey,
                );
              } else if (isFromDifferentBooking) {
                // منع اختيار ساعة من حجز مختلف
                _showStatusMessage(
                  context,
                  context.tr('msg_one_booking_at_a_time'),
                  Colors.orange,
                );
              } else {
                // نمرر الموديل بالكامل عشان الـ ActionBar ياخد منه الاسم والرقم
                onSlotTap(
                  slot,
                  isBookedByOthers,
                  isBookedByOthers ? bookingDetails : null,
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(
                  color: isSelected ? ColorManager.wasabi : Colors.transparent,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(leadingIcon, color: contentColor),
                title: Text(
                  _formatToLocal12Hour(context, slot),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: contentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStatusMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
