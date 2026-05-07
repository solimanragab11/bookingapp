import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/widgets/build_info_column.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/widgets/build_status_badge.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCardWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    // 1. استخراج البيانات (Logic Separation)
    final double total = (booking['totalPrice'] ?? 0).toDouble();
    final double paid = (booking['paidAmount'] ?? 0).toDouble();
    final double remaining = total - paid;
    final String orderId = booking['id'] ?? "N/A";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: _buildCardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, orderId),
                const SizedBox(height: 10),
                _buildMainInfo(context),
                const Divider(color: Colors.white12),
                _buildPaymentRow(context, paid, remaining, total),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets (Clean & Readable) ---

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: ColorManager.cardSurface.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    );
  }

  Widget _buildHeader(BuildContext context, String orderId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "ID: #$orderId",
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
        BuildStatusBadge(context: context),
      ],
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    final placeInfo = booking['placeInfo'] as Map<String, dynamic>?;
    final String fullDay = booking['timeSlots']?.keys?.first ?? "";

    // منطق الترجمة هنا بيبقى معزول
    String day = fullDay.split(' ').first.toLowerCase();
    String date = fullDay.contains(' ') ? fullDay.split(' ').last : "";

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: ColorManager.wasabi,
        child: const Icon(Icons.sports_soccer, color: Colors.white),
      ),
      title: Text(
        "${placeInfo?['name'] ?? 'Place'} - ${booking['subPlaceId']}",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        "${context.tr(day)} $date\n${booking['timeSlots']?.values?.first?.join(', ') ?? ''}",
        style: TextStyle(color: Colors.white.withOpacity(0.6)),
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    double paid,
    double remaining,
    double total,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BuildInfoColumn(
          label: context.tr('paid'),
          amount: "$paid EGP",
          color: ColorManager.wasabi,
        ),
        BuildInfoColumn(
          label: context.tr('remaining'),
          amount: "$remaining EGP",
          color: Colors.orangeAccent,
        ),
        BuildInfoColumn(
          label: context.tr('total'),
          amount: "$total EGP",
          color: Colors.white,
        ),
      ],
    );
  }
}
