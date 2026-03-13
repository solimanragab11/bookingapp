import 'package:cloud_functions/cloud_functions.dart';

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Get wallet payment URL from Paymob
  /// Amount should be in piastres (cents): 150 EGP = 15000 piastres
  Future<String?> getWalletPaymentUrl({
    required double amount,
    required String phone,
  }) async {
    try {
      print(
        '[PaymentService] Creating payment link for amount: $amount piastres',
      );

      final HttpsCallable callable = _functions.httpsCallable(
        'createPaymentLink',
      );

      final HttpsCallableResult result = await callable.call(<String, dynamic>{
        "amount": amount.toInt(), // Paymob requires integer piastres
        "phone": phone,
      });

      print('[PaymentService] Backend response: ${result.data}');

      if (result.data != null) {
        final data = Map<String, dynamic>.from(result.data);
        final isSuccess = data['success'] == true;
        final url = data['url']?.toString();

        print('[PaymentService] Success: $isSuccess, URL: $url');

        if (isSuccess && url != null && url.isNotEmpty) {
          return url;
        }
      }
      return null;
    } catch (e) {
      print('[PaymentService] Error: $e');
      print('[PaymentService] Stack trace: ${StackTrace.current}');
      return null;
    }
  }
}
