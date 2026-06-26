import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class VenueQrGenerator extends StatefulWidget {
  final String venueId;
  final String venueName;

  const VenueQrGenerator({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<VenueQrGenerator> createState() => _VenueQrGeneratorState();
}

class _VenueQrGeneratorState extends State<VenueQrGenerator> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareQrCode() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // Small delay to ensure the boundary has completed painting
      await Future.delayed(const Duration(milliseconds: 100));

      final RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception("Failed to find boundary context");
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception("Failed to convert image to bytes");
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/venue_qr_${widget.venueId}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'كود الدخول الذكي لملعب ${widget.venueName}',
      );
    } catch (e) {
      debugPrint("❌ Error sharing QR code: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء حفظ أو مشاركة الكود: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // السلسلة النصية اللي هتتخزن جوه الكود ومستحيل تتكرر
    final String qrData = 'hanzbthalk_venue_${widget.venueId}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: _globalKey,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white, // خلفية بيضاء ضرورية عشان الكاميرا تقرأ الكود
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "كود الدخول الذكي",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "ملعب ${widget.venueName}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // رسم الـ QR Code
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 220.0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // زرار مشاركة أو حفظ كود الـ QR
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSharing ? null : _shareQrCode,
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share_rounded),
            label: Text(_isSharing ? "جاري تحضير الكود..." : "مشاركة وحفظ كود الطباعة"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
