import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_cubit.dart';

class PaymentStatusDialog extends StatelessWidget {
  final bool isSuccess;
  final double paidAmount;

  const PaymentStatusDialog({
    super.key,
    required this.isSuccess,
    required this.paidAmount,
  });

  @override
  Widget build(BuildContext context) {
    // Confirm booking if payment was successful
    if (isSuccess) {
      Future.delayed(Duration.zero, () {
        try {
          final cubit = context.read<BookingCubit>();
          cubit.confirmBooking(
            userId: 'test_user_123', // TODO: Get actual user ID
            paidAmount: paidAmount,
          );
        } catch (e) {
          print('[PaymentStatusDialog] Error confirming booking: $e');
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
