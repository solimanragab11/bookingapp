import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// تأكيد استخدام الـ package name الصحيح لأي حجة تانية هتحتاجها هنا مستقبلاً
// import 'package:remaking_booking_app_trail2/...';

class CheckInScannerScreen extends StatefulWidget {
  const CheckInScannerScreen({super.key});

  @override
  State<CheckInScannerScreen> createState() => _CheckInScannerScreenState();
}

class _CheckInScannerScreenState extends State<CheckInScannerScreen> {
  bool isScanCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("مسح كود الملعب"), centerTitle: true),
      body: Stack(
        children: [
          // 🎥 الكاميرا اللي بتقرأ الـ QR
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed:
                  DetectionSpeed.noDuplicates, // عشان ميعملش سكان مرتين ورا بعض
              facing: CameraFacing.back,
            ),
            onDetect: (capture) {
              if (isScanCompleted) return;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? rawValue = barcode.rawValue;
                if (rawValue != null &&
                    rawValue.startsWith('hanzbthalk_venue_')) {
                  setState(() {
                    isScanCompleted = true;
                  });

                  // 🔴 هنا لقطنا الـ ID بنجاح!
                  final venueId = rawValue.replaceFirst(
                    'hanzbthalk_venue_',
                    '',
                  );

                  // بنقفل الشاشة ونرجع بالـ ID للـ Cubit عشان يعمل الـ Validation
                  Navigator.pop(context, venueId);
                  break;
                }
              }
            },
          ),

          // 🎨 طبقة فوق الكاميرا عشان تدي شكل "برواز" الـ Scan الذكي
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
