import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class BuildStatusBadge extends StatelessWidget {
  final double paidAmount;
  final double totalPrice;

  const BuildStatusBadge({
    super.key,
    required this.paidAmount,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final double remaining = totalPrice - paidAmount;
    final String statusKey;
    final Color badgeColor;
    final Color textColor;

    if (remaining <= 0) {
      statusKey = 'fullyPaid';
      badgeColor = ColorManager.emeraldGreen.withOpacity(0.15);
      textColor = ColorManager.wasabi;
    } else if (paidAmount > 0) {
      statusKey = 'depositPaid';
      badgeColor = ColorManager.egyptianEarth.withOpacity(0.15);
      textColor = ColorManager.egyptianEarth;
    } else {
      statusKey = 'confirmed';
      badgeColor = ColorManager.wasabi.withOpacity(0.15);
      textColor = ColorManager.wasabi;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1.0,
        ),
      ),
      child: Text(
        context.tr(statusKey),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
