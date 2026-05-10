import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_states.dart';

class PaymentStatusDialog extends StatelessWidget {
  final bool isSuccess;
  final double paidAmount;
  final String orderId;
  // تعريف الـ userId مباشرة من Firebase
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

  PaymentStatusDialog({
    super.key,
    required this.isSuccess,
    required this.paidAmount,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    if (isSuccess) {
      Future.delayed(Duration.zero, () {
        // ignore: use_build_context_synchronously
        final cubit = context.read<BookingCubit>();

        // التحقق من أن الحالة BookingDataState قبل التأكيد
        if (cubit.state is BookingDataState) {
          final currentState = cubit.state as BookingDataState;
          cubit.confirmBooking(amountToPay: paidAmount);

          // Debug عشان تتأكد في الـ Terminal
          debugPrint('🎯 Sending Booking: isOffer = ${currentState.isOffer}');
        }
      });
    }
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Icon(
        isSuccess ? Icons.check_circle : Icons.error,
        color: isSuccess ? Colors.green : Colors.red,
        size: 60,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSuccess
                ? context.tr('paymentSuccess')
                : context.tr('paymentFailed'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            isSuccess
                ? context.tr('bookingConfirmedSuccess')
                : context.tr('paymentFailedMessage'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('ok')),
        ),
      ],
    );
  }
}
