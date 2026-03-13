import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/features/user/payment/widgets/payment_status_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final double paidAmount;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.paidAmount,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFinished = false; // حاجز أمان عشان الـ Dialog ميتفتحش مرتين

  @override
  void initState() {
    super.initState();

    // تعريف الكنترولر هنا أضمن يا عمي السولي
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("رابط الدفع من السيرفر: $url");
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (request) {
            debugPrint(
              "التنقل لـ: ${request.url}",
            ); // عشان تتابع الروابط في الـ Console

            if (request.url.contains('success=true')) {
              print("--------------------");

              _finishPayment(true);
              return NavigationDecision.prevent;
            } else if (request.url.contains('success=false')) {
              _finishPayment(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    if (_isFinished) return; // لو قفلنا خلاص اخرج

    if (url.contains('success=true')) {
      print("--------------------");
      _finishPayment(true);
    } else if (url.contains('success=false')) {
      _finishPayment(false);
      print("----------+++++----------");
    }
  }

  void _finishPayment(bool isSuccess) {
    if (_isFinished) return; // منع التكرار
    _isFinished = true;

    if (mounted) {
      Navigator.pop(context); // اقفل شاشة الـ WebView
      showDialog(
        context: context,
        barrierDismissible: false, // المستخدم ميقفلش الدايالوج بالضغط بره
        builder: (context) => PaymentStatusDialog(
          isSuccess: isSuccess,
          paidAmount: widget.paidAmount,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('confirmWalletPayment')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),
        ],
      ),
    );
  }
}
