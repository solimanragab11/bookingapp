import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/repos/pricing_repository.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';

class CancelConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> booking;
  final DateTime startTime;

  const CancelConfirmationDialog({
    super.key,
    required this.booking,
    required this.startTime,
  });

  static void show(
    BuildContext context,
    Map<String, dynamic> booking,
    DateTime startTime,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "CancelConfirmation",
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: 0.90 + 0.10 * curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8.0 * anim1.value,
                sigmaY: 8.0 * anim1.value,
              ),
              child: CancelConfirmationDialog(
                booking: booking,
                startTime: startTime,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double amountPaidOnline = (booking['paidAmount'] ?? 0.0).toDouble();
    final double deposit = (booking['requiredDeposit'] ?? 0.0).toDouble();
    final refund = getIt<PricingRepository>().calculateRefund(
      amountPaidOnline: amountPaidOnline,
      deposit: deposit,
      bookingStartTime: startTime,
    );

    return AlertDialog(
      backgroundColor: ColorManager.cardSurface.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
      ),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr('confirmCancellation'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "هل أنت متأكد من إلغاء هذا الحجز؟ / Are you sure you want to cancel this booking?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          _buildRefundDetailRow(
            "المبلغ المدفوع أونلاين / Paid Online:",
            "$amountPaidOnline EGP",
          ),
          const SizedBox(height: 6),
          _buildRefundDetailRow(
            "مبلغ العربون المستحق / Required Deposit:",
            "$deposit EGP",
          ),
          const SizedBox(height: 6),
          _buildRefundDetailRow(
            "المبلغ المسترد المتوقع / Expected Refund:",
            "$refund EGP",
            valueColor: ColorManager.wasabi,
            isBold: true,
          ),
          const SizedBox(height: 12),
          const Text(
            "* تطبق سياسة الإلغاء والاسترداد المعتمدة.\n* Standard cancellation policy applies.",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            context.tr('cancelBtn'),
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            final String userId = booking['userId'] ?? "";
            context.read<UserBookingsCubit>().cancelBooking(
              bookingData: booking,
              userId: userId,
              expectedRefund: refund,
            );
          },
          child: const Text(
            "تأكيد الإلغاء / Confirm",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRefundDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
