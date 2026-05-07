import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Get wallet payment URL from Paymob
  /// Amount should be in piastres (cents): 150 EGP = 15000 piastres
  Future<String?> getWalletPaymentUrl({
    required double amount,
    required String phone,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable(
        'handleUserPayment',
      );

      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        "amount": amount.toInt(), // Paymob requires integer piastres
        "phone": phone,
      });

      if (result.data != null) {
        final data = Map<String, dynamic>.from(result.data);
        final isSuccess = data['success'] == true;
        final url = data['url']?.toString();

        if (isSuccess && url != null && url.isNotEmpty) {
          return url;
        }
      }
      return null;
    } catch (e) {
      debugPrint('[PaymentService] Error: $e');
      return null;
    }
  }
}
