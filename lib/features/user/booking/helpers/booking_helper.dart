import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/features/user/payment/payment_service.dart';
import 'package:remaking_booking_app_trail2/features/user/payment/payment_web_view.dart';

mixin BookingHelper {
  /// Format time slot from "HH:mm" to "h:mm AM/PM" format
  String formatTimeSlot(String slot) {
    final hour = int.parse(slot.split(':')[0]);
    final period = hour < 12 ? 'AM' : 'PM';
    int h12 = hour % 12 == 0 ? 12 : hour % 12;
    return '${h12.toString().padLeft(2, '0')}:00 $period';
  }

  /// Show snack bar notification
  void showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  /// Handle wallet payment by getting payment URL and opening WebView
  Future<void> handleWalletPayment(
    BuildContext context,
    double amount,
    String phone,
  ) async {
    // Validate amount
    if (amount <= 0) {
      if (!context.mounted) return;
      showSnackBar(context, context.tr('invalidAmount'), Colors.red);
      return;
    }

    // 1. Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Convert amount to piastres (Paymob requires amount in cents)
      // Example: 150 EGP = 15000 piastres
      final amountInPiastres = (amount).toInt();
      print(
        '[PaymentFlow] Converting amount: $amount EGP → $amountInPiastres piastres',
      );

      // 3. Get payment URL from server
      print('[PaymentFlow] Requesting payment URL from PaymentService...');
      print('[PaymentFlow] Amount: $amountInPiastres piastres, Phone: $phone');

      final paymentUrl = await PaymentService().getWalletPaymentUrl(
        amount: amountInPiastres.toDouble(),
        phone: phone,
      );

      print('[PaymentFlow] Response: paymentUrl = $paymentUrl');

      // Close loading dialog safely
      if (!context.mounted) return;
      Navigator.pop(context);

      // 4. Check if URL is valid
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        print('[PaymentFlow] Opening WebView with URL: $paymentUrl');

        // 5. Open WebView safely
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              paymentUrl: paymentUrl,
              paidAmount: amount,
            ),
          ),
        );
      } else {
        // Show error if no valid URL received
        if (!context.mounted) return;
        print('[PaymentFlow] ERROR: Received null or empty URL from server');
        showSnackBar(context, context.tr('failedPaymentUrl'), Colors.red);
      }
    } catch (e) {
      print('[PaymentFlow] Exception occurred: $e');
      print('[PaymentFlow] Stack trace: ${StackTrace.current}');

      // Close loading dialog safely
      if (!context.mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error message
      if (!context.mounted) return;
      showSnackBar(context, context.tr('errorProcessingPayment'), Colors.red);
    }
  }
}
