import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/features/user/booking/cubit/booking_cubit.dart';
import 'package:hanzbthalk/features/user/payment/payment_service.dart';
import 'package:hanzbthalk/features/user/payment/payment_web_view.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';

mixin BookingHelper {
  // دالة مساعدة لتنسيق الوقت
  String formatTimeSlot(String slot) {
    final hour = int.parse(slot.split(':')[0]);
    final period = hour < 12 ? 'AM' : 'PM';
    int h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:00 $period';
  }

  // دالة إظهار الرسائل
  void showSnackBar(BuildContext context, String msg, Color color) {
    if (color == Colors.red) {
      SnackBarUtils.showError(context, msg);
    } else {
      SnackBarUtils.showSuccess(context, msg);
    }
  }

  // الدالة الأساسية للدفع
  Future<void> handleWalletPayment(
    BuildContext context,
    double amount,
    String phone,
  ) async {
    // سحب الـ Cubit من الـ context اللي جاي من الشاشة
    final bookingCubit = BlocProvider.of<BookingCubit>(context);

    if (amount <= 0) {
      showSnackBar(context, context.tr('invalidAmount'), Colors.red);
      return;
    }

    // إظهار اللودينج
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final paymentUrl = await PaymentService().getWalletPaymentUrl(
        amount: amount,
        phone: phone,
      );
      debugPrint(paymentUrl);
      if (context.mounted) Navigator.pop(context); // قفل اللودينج

      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        if (context.mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebViewScreen(
                paymentUrl: paymentUrl,
                paidAmount: amount,
                bookingCubit: bookingCubit, // تمرير الـ Cubit للـ WebView
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          showSnackBar(context, context.tr('failedPaymentUrl'), Colors.red);
        }
      }
    } catch (e) {
      if (context.mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        showSnackBar(context, context.tr('errorProcessingPayment'), Colors.red);
      }
    }
  }
}
