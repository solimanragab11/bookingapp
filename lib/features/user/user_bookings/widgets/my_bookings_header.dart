import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/details_glass_button.dart';

class MyBookingsHeader extends StatelessWidget {
  const MyBookingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          DetailsGlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            context.tr('myBookings'),
            style: TextStyleMangare.headingStyle.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 46), // Balance the glass back button
        ],
      ),
    );
  }
}
