import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/build_info_column.dart';

class BookingPaymentSummary extends StatelessWidget {
  final double paid;
  final double remaining;
  final double total;

  const BookingPaymentSummary({
    super.key,
    required this.paid,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.tr('egp');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BuildInfoColumn(
          label: context.tr('paid'),
          amount: "${paid.toStringAsFixed(0)} $currency",
          color: ColorManager.wasabi,
        ),
        BuildInfoColumn(
          label: context.tr('remaining'),
          amount: "${remaining.toStringAsFixed(0)} $currency",
          color: ColorManager.egyptianEarth,
        ),
        BuildInfoColumn(
          label: context.tr('total'),
          amount: "${total.toStringAsFixed(0)} $currency",
          color: Colors.white,
        ),
      ],
    );
  }
}
