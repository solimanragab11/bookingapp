import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';

class SnackBarUtils {
  /// دالة لإظهار SnackBar باللون الأحمر للأخطاء
  static void showErrorSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent, // ضفنا لون أحمر عشان ده خطأ
        behavior:
            SnackBarBehavior.floating, // بيخلي شكلها أشيك ومرفوعة عن الأرض
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          "${context.tr('errorSaving')} $msg",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
