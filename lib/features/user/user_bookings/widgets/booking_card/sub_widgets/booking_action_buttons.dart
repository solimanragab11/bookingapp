import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/check_booking/cubit/check_in_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/cancel_confirmation_dialog.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_time_helper.dart';

class BookingActionButtons extends StatelessWidget {
  final Map<String, dynamic> booking;
  final PlaceModel? placeModel;
  final DateTime startTime;
  final bool isFutureBooking;

  const BookingActionButtons({
    super.key,
    required this.booking,
    required this.placeModel,
    required this.startTime,
    required this.isFutureBooking,
  });

  void _showPinSuccessDialog(BuildContext context, String pin) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorManager.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(
              color: ColorManager.emeraldGreen,
              width: 1.5,
            ),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.emeraldGreen.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  color: ColorManager.emeraldGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(
                  'cash_pin_created_title',
                  defaultValue: 'Verification PIN Generated',
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr(
                  'cash_pin_created_desc',
                  defaultValue:
                      'Please pay the remaining amount in cash to the employee at the field, and show them this PIN code to confirm receipt:',
                ),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12, width: 1.0),
                ),
                child: Text(
                  pin.split('').join('  '), // Spaced out PIN e.g. "1  2  3  4"
                  style: const TextStyle(
                    color: ColorManager.creasedKhaki,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.emeraldGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.tr('ok', defaultValue: 'OK'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePayCash(BuildContext context) async {
    final String bookingId = booking['id'] ?? '';
    final String userId = booking['userId'] ?? '';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: ColorManager.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: ColorManager.creasedKhaki, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.monetization_on_outlined,
              color: ColorManager.creasedKhaki,
            ),
            const SizedBox(width: 10),
            Text(
              context.tr(
                'confirm_pay_cash_title',
                defaultValue: 'Pay Cash at Field',
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          context.tr(
            'confirm_pay_cash_msg',
            defaultValue:
                'To pay the remaining balance in cash, a verification PIN will be generated. Please show this PIN to the employee at the field to confirm cash receipt. Generate PIN?',
          ),
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(
              context.tr('cancelBtn', defaultValue: 'Cancel'),
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.creasedKhaki,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              context.tr('confirm', defaultValue: 'Confirm'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final random = Random();
        final pin = (random.nextInt(9000) + 1000).toString();

        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .update({'cashPin': pin, 'isCash': true});

        if (context.mounted) {
          Navigator.pop(context); // Close loading spinner
          // Refresh list
          context.read<UserBookingsCubit>().fetchMyBookings(userId);
          // Show verification PIN success dialog
          _showPinSuccessDialog(context, pin);
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading spinner
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr(
                  'error_occurred',
                  defaultValue: 'An error occurred. Please try again.',
                ),
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? endTime = BookingTimeHelper.getBookingEndTime(booking);
    final now = DateTime.now();

    // 15 mins before start time
    final checkInStartTime = startTime.subtract(const Duration(minutes: 15));

    // Show button until the end of the booking time (E)
    final bool showCheckInButton = endTime != null && now.isBefore(endTime);

    // Clickable if now is between S-15m and E
    final bool isCheckInClickable =
        showCheckInButton && now.isAfter(checkInStartTime);

    final double total = (booking['totalPrice'] ?? 0).toDouble();
    final double paid = (booking['paidAmount'] ?? 0).toDouble();
    final double remaining = total - paid;
    final String status = booking['status'] ?? "active";
    final bool showPayRestButton =
        remaining > 0 && (status == 'active' || status == 'attended');

    final bool showPayCash =
        showPayRestButton &&
        (booking['cashPin'] == null || (booking['cashPin'] as String).isEmpty);

    // ❌ Cancel button logic:
    // - The booking must be in the future (not started yet)
    // - The booking must be at least 2 hours away
    // - The booking status must be 'active'
    final Duration timeUntilStart = startTime.difference(now);
    final bool canCancel =
        isFutureBooking &&
        status == 'active' &&
        timeUntilStart >= const Duration(hours: 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showPayCash) ...[
          _buildActionButton(
            context: context,
            label: context.tr('pay_rest_btn', defaultValue: 'Pay Rest'),
            icon: Icons.monetization_on_rounded,
            color: ColorManager.creasedKhaki,
            onTap: () => _handlePayCash(context),
          ),
          const SizedBox(width: 8),
        ],

        if (showCheckInButton) ...[
          // 🎯 زرار الـ QR Check-In
          _buildActionButton(
            context: context,
            label: context.tr('checkIn', defaultValue: 'تسجيل الحضور'),
            icon: Icons.qr_code_scanner_rounded,
            color: isCheckInClickable ? ColorManager.emeraldGreen : Colors.grey,
            onTap: isCheckInClickable
                ? () {
                    Navigator.pushNamed(context, Routes.checkInScanner).then((
                      scannedVenueId,
                    ) {
                      if (scannedVenueId != null &&
                          scannedVenueId is String &&
                          context.mounted) {
                        final String userId = booking['userId'] ?? "";
                        getIt<CheckInCubit>().validateAndCheckIn(
                          userId: userId,
                          scannedVenueId: scannedVenueId,
                        );
                      }
                    });
                  }
                : null,
          ),
          const SizedBox(width: 8),
        ],

        // ❌ زرار الإلغاء — يختفي لو الحجز أقل من ساعتين أو مش active
        if (canCancel) ...[
          _buildActionButton(
            context: context,
            label: context.tr('cancelBtn'),
            icon: Icons.cancel_outlined,
            color: Colors.redAccent,
            onTap: () =>
                CancelConfirmationDialog.show(context, booking, startTime),
          ),
          const SizedBox(width: 8),
        ],

        // 🔄 زرار إعادة الحجز
        if (placeModel != null &&
            (!isFutureBooking ||
                status == 'canceled' ||
                status == 'no_show' ||
                status == 'attended'))
          _buildActionButton(
            context: context,
            label: context.tr('rebook'),
            icon: Icons.refresh_rounded,
            color: ColorManager.egyptianEarth,
            onTap: () => Navigator.pushNamed(
              context,
              Routes.placeDetails,
              arguments: placeModel,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, color: color, size: 14),
          ],
        ),
      ),
    );
  }
}
