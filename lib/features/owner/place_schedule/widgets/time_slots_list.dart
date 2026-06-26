// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/db/permission_service.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/owner/place_schedule/widgets/booking_details_bottom_sheet.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';

class TimeSlotsList extends StatelessWidget {
  final List<SubPlaceModel> subPlaces;
  final SlotsModel? slots;
  final DateTime selectedDate;
  final int subPlaceIndex;
  final List<String> selectedSlots;
  final String? activeBookingId;
  final void Function(String slot, bool isBooked, BookingIdModel? booking)
  onSlotTap;

  const TimeSlotsList({
    super.key,
    required this.subPlaces,
    required this.slots,
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

    String? matchedDayKey;
    if (slots != null) {
      final dayStr = DateFormat('dd/MM', 'en').format(selectedDate);
      for (var key in slots!.freeTimeSlots.keys) {
        if (key.endsWith(dayStr)) {
          matchedDayKey = key;
          break;
        }
      }
      if (matchedDayKey == null) {
        for (var booking in slots!.bookedTimeSlots) {
          for (var key in booking.slots.keys) {
            if (key.endsWith(dayStr)) {
              matchedDayKey = key;
              break;
            }
          }
          if (matchedDayKey != null) break;
        }
      }
    }
    final dayKey =
        matchedDayKey ??
        DateFormat('EEEE dd/MM', 'en').format(selectedDate).toLowerCase();

    if (slots == null || subPlaceIndex >= subPlaces.length) {
      return const Center(
        child: CircularProgressIndicator(color: ColorManager.wasabi),
      );
    }

    final List<String> free = List.from(slots!.freeTimeSlots[dayKey] ?? []);
    final List<String> booked = slots!.bookedTimeSlots
        .expand((booking) => booking.slots[dayKey] ?? <String>[])
        .toList();

    final List<String> all = [...free, ...booked];

    // Check if there are no slots at all for this day (handling closed days)
    if (all.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: Colors.white.withOpacity(0.4),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('no_schedule_available'),
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
      );
    }

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
        final bookingDetails = slots!.bookedTimeSlots.firstWhere(
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

        // التحقق من حالة القفل المؤقت في الداتابيز
        final String slotId = '${dayKey}_$slot';
        bool isLockedByYou = isSelected;
        bool isLockedByOthers = false;

        if (slots?.lockedSlots != null &&
            slots!.lockedSlots.containsKey(slotId)) {
          final lockInfo = Map<String, dynamic>.from(
            slots!.lockedSlots[slotId],
          );
          final expiresAt = lockInfo['expiresAt'] as Timestamp;
          final lockUserId = lockInfo['userId'] as String;

          if (expiresAt.toDate().isAfter(DateTime.now())) {
            final authUser = context.read<AuthCubit>().currentUser;
            if (lockUserId == authUser?.id) {
              isLockedByYou = true;
            } else {
              isLockedByOthers = true;
            }
          }
        }

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
        Color borderColor;
        IconData leadingIcon = Icons.access_time_filled;

        if (isBookedByUser) {
          statusText = context.tr('booked_by_app');
          bgColor = Colors.grey.withOpacity(0.15);
          contentColor = Colors.white60;
          borderColor = Colors.white10;
          leadingIcon = Icons.lock;
        } else if (isBookedByOwner) {
          statusText =
              "${bookingDetails.bookedBy}\n${bookingDetails.bookername}";
          bgColor = isFromDifferentBooking
              ? Colors.orange.withOpacity(0.05)
              : Colors.orange.withOpacity(0.15);
          contentColor = isFromDifferentBooking
              ? Colors.orange.withOpacity(0.3)
              : Colors.orange;
          borderColor = isFromDifferentBooking
              ? Colors.orange.withOpacity(0.1)
              : Colors.orange.withOpacity(0.4);
        } else if (isPast) {
          statusText = context.tr('past_status');
          bgColor = Colors.redAccent.withOpacity(0.15);
          contentColor = Colors.white;
          borderColor = Colors.redAccent.withOpacity(0.5);
        } else if (isLockedByOthers) {
          // محجوز مؤقتاً من مستخدم آخر (Orange/Amber)
          statusText = context.tr('in_process_other');
          bgColor = Colors.orange.withOpacity(0.25);
          contentColor = Colors.orangeAccent;
          borderColor = Colors.orangeAccent;
          leadingIcon = Icons.pending_actions_rounded;
        } else if (isLockedByYou) {
          // محجوز مؤقتاً بواسطة الموظف/المالك الحالي (Purple)
          statusText = context.tr('in_process_yours');
          bgColor = Colors.purple.shade400;
          contentColor = Colors.white;
          borderColor = Colors.purpleAccent;
          leadingIcon = Icons.check_circle;
        } else {
          statusText = context.tr('available_status');
          bgColor = ColorManager.noirDeVigne.withOpacity(0.6);
          contentColor = ColorManager.creasedKhaki;
          borderColor = ColorManager.emeraldGreen.withOpacity(0.35);
        }

        return Opacity(
          opacity: (isBookedByUser || isFromDifferentBooking) ? 0.5 : 1.0,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();

              if (isPast && !isBookedByOthers) {
                _showStatusMessage(
                  context,
                  context.tr('msg_time_started'),
                  Colors.redAccent,
                );
              } else if (isBookedByOthers) {
                if (bookingDetails.bookedBy == 'user') {
                  BookingDetailsBottomSheet.show(
                    context: context,
                    bookingId: bookingDetails.bookingId,
                    bookerName: bookingDetails.bookername,
                    bookedBy: bookingDetails.bookedBy,
                    slotTime: _formatToLocal12Hour(context, slot),
                    rawSlotTime: slot,
                    canCancel: false,
                    onSelectForCancellation: () {},
                  );
                  return;
                }

                if (selectedSlots.isEmpty) {
                  final currentUser = context.read<AuthCubit>().currentUser;
                  final canCancel =
                      currentUser != null &&
                      PermissionService.can(currentUser, 'cancelBooking');

                  BookingDetailsBottomSheet.show(
                    context: context,
                    bookingId: bookingDetails.bookingId,
                    bookerName: bookingDetails.bookername,
                    bookedBy: bookingDetails.bookedBy,
                    slotTime: _formatToLocal12Hour(context, slot),
                    rawSlotTime: slot,
                    canCancel: canCancel,
                    onSelectForCancellation: () {
                      onSlotTap(slot, true, bookingDetails);
                    },
                  );
                } else {
                  if (isFromDifferentBooking) {
                    _showStatusMessage(
                      context,
                      context.tr('msg_one_booking_at_a_time'),
                      Colors.orange,
                    );
                  } else {
                    onSlotTap(slot, true, bookingDetails);
                  }
                }
              } else if (isLockedByOthers) {
                _showStatusMessage(
                  context,
                  context.tr('slot_busy_now'),
                  Colors.orangeAccent,
                );
              } else {
                onSlotTap(slot, false, null);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 1.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Icon(leadingIcon, color: contentColor),
                title: Text(
                  _formatToLocal12Hour(context, slot),
                  style: const TextStyle(
                    color: Colors.white,
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
    if (color == Colors.redAccent) {
      SnackBarUtils.showError(context, message);
    } else {
      SnackBarUtils.showInfo(context, message);
    }
  }
}
