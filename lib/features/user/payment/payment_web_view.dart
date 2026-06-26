import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/features/user/booking/cubit/booking_cubit.dart';
import 'package:hanzbthalk/features/user/payment/widgets/payment_status_dialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final double paidAmount;
  final BookingCubit? bookingCubit;
  final String? existingBookingId;
  final VoidCallback? onPaymentFinished;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.paidAmount,
    this.bookingCubit,
    this.existingBookingId,
    this.onPaymentFinished,
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

    final String userAgent = Platform.isIOS
        ? "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
        : "Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);

            // Inject CSS and Meta tag to force responsiveness and scrollability
            try {
              _controller.runJavaScript("""
                (function() {
                  var style = document.createElement('style');
                  style.innerHTML = 'html, body { overflow: auto !important; height: auto !important; min-height: 100% !important; }';
                  document.head.appendChild(style);
                  
                  var meta = document.createElement('meta');
                  meta.name = 'viewport';
                  meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
                  document.head.appendChild(meta);
                })();
              """);
            } catch (e) {
              debugPrint("Error injecting viewport and scroll CSS: \$e");
            }

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

    if (isSuccess && widget.existingBookingId != null) {
      try {
        final docRef = FirebaseFirestore.instance.collection('bookings').doc(widget.existingBookingId);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            final double currentPaid = (snapshot.data()?['paidAmount'] ?? 0.0).toDouble();
            final double newPaid = currentPaid + widget.paidAmount;
            transaction.update(docRef, {
              'paidAmount': newPaid,
              'isCashSettled': true,
            });
          }
        });
        debugPrint("✅ Firestore updated successfully for existing booking: ${widget.existingBookingId}");
      } catch (e) {
        debugPrint("❌ Error updating Firestore for existing booking: $e");
      }
    }

    if (mounted) {
      // قفل الـ WebView
      Navigator.pop(context);

      Widget dialog = PaymentStatusDialog(
        isSuccess: isSuccess,
        paidAmount: widget.paidAmount,
        orderId: finalOrderId,
        isExistingBookingPayment: widget.existingBookingId != null,
        onPaymentFinished: widget.onPaymentFinished,
      );

      if (widget.bookingCubit != null) {
        dialog = BlocProvider.value(
          value: widget.bookingCubit!,
          child: dialog,
        );
      }

      // إظهار دايالوغ النتيجة
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => dialog,
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
