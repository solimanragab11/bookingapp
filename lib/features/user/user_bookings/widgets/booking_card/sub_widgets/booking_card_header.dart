import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';

class BookingCardHeader extends StatelessWidget {
  final String orderId;
  final String status; // 🎯 ضفنا متغير الحالة هنا

  const BookingCardHeader({
    super.key,
    required this.orderId,
    required this.status, // 🎯 مطلوب إرسال الحالة من الكارت الرئيسي
  });

  @override
  Widget build(BuildContext context) {
    final String displayId = orderId.length > 8
        ? orderId.substring(0, 8).toUpperCase()
        : orderId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. رقم الطلب
        Expanded(
          child: Text(
            "${context.tr('orderIdLabel')}$displayId",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // 2. حالة الحجز (الـ Chip الجديد)
        _buildBookingStatusChip(context, status),
      ],
    );
  }

  // 🎨 دالة بترسم بادج الحالة بالألوان بناءً على الكلمة اللي جاية من الفايربيز
  Widget _buildBookingStatusChip(BuildContext context, String currentStatus) {
    Color bgColor;
    Color textColor;
    String labelText;

    switch (currentStatus.toLowerCase()) {
      case 'attended':
        bgColor = Colors.green.withOpacity(0.15);
        textColor = Colors.greenAccent;
        labelText = context.tr('status_attended', defaultValue: 'تم الحضور');
        break;
      case 'pending_no_show':
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orangeAccent;
        labelText = context.tr(
          'status_pending_no_show',
          defaultValue: 'معلق - مراجعة',
        );
        break;
      case 'no_show':
        bgColor = Colors.red.withOpacity(0.15);
        textColor = Colors.redAccent;
        labelText = context.tr('status_no_show', defaultValue: 'لم يحضر');
        break;
      case 'canceled':
        bgColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey;
        labelText = context.tr('status_canceled', defaultValue: 'ملغي');
        break;
      case 'active':
      default:
        bgColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blueAccent;
        labelText = context.tr('status_active', defaultValue: 'نشط');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
