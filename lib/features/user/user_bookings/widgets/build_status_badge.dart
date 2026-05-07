import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class BuildStatusBadge extends StatelessWidget {
  const BuildStatusBadge({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorManager.wasabi.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        context.tr('confirmed'),
        style: const TextStyle(
          color: ColorManager.egyptianEarth,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
