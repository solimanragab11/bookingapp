import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';

class MyBookingsHeader extends StatelessWidget {
  const MyBookingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: ColorManager.wasabi),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            context.tr('myBookings'),
            style: TextStyleMangare.headingStyle.copyWith(
              color: ColorManager.wasabi,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // لموازنة حجم الـ IconButton
        ],
      ),
    );
  }
}
