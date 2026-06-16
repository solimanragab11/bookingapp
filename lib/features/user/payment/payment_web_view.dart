import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/features/user/booking/cubit/booking_cubit.dart';
import 'package:hanzbthalk/features/user/payment/widgets/payment_status_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final double paidAmount;
  final BookingCubit bookingCubit;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.paidAmount,
    required this.bookingCubit,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            // بنفحص الحالة برضه عند نهاية تحميل أي صفحة
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (request) {
            final url = request.url;

            // فحص النجاح من الـ URL (زي ما ظهر في اللوج عندك)
            if (url.contains('success=true')) {
              final uri = Uri.parse(url);
              final orderIdFromUrl = uri.queryParameters['order'];

              debugPrint("✅ نجاح الدفع! Order ID المستخرج: $orderIdFromUrl");

              _finishPayment(true, orderIdFromUrl);
              return NavigationDecision.prevent;
            }

            // فحص الفشل
            if (url.contains('success=false')) {
              debugPrint("❌ فشل الدفع أو تم إلغاؤه");
              _finishPayment(false, null);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // دالة فحص إضافية للأمان عند انتهاء التحميل
  void _checkPaymentStatus(String url) {
    if (_isFinished) return;

    if (url.contains('success=true')) {
      final uri = Uri.parse(url);
      final orderIdFromUrl = uri.queryParameters['order'];
      _finishPayment(true, orderIdFromUrl);
    } else if (url.contains('success=false')) {
      _finishPayment(false, null);
    }
  }

  void _finishPayment(bool isSuccess, String? orderIdFromUrl) async {
    if (_isFinished) return;
    _isFinished = true;

    // الأولوية للي جاي من الـ URL، لو مش موجود نستخدم اللي جاي من السيرفر
    final String finalOrderId = orderIdFromUrl ?? "رقم الطلب غير متوفر";

    if (mounted) {
      // قفل الـ WebView
      Navigator.pop(context);
      // إظهار دايالوغ النتيجة
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider.value(
          value: widget.bookingCubit,
          child: PaymentStatusDialog(
            isSuccess: isSuccess,
            paidAmount: widget.paidAmount,
            orderId: finalOrderId,
          ),
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
        // منع الرجوع بالخلف لإجبار المستخدم على إكمال العملية أو انتظار الـ Callback
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finishPayment(false, null),
        ),
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
