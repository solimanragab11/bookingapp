import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/lang_button.dart';

class CustAppBar extends StatelessWidget {
  CustAppBar({super.key, required this.width});
  final double width;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: ColorManager.wasabi),
          ),
          const Spacer(),
          Text(
            context.tr('addNewPlace'),
            style: TextStyle(
              color: ColorManager.wasabi,
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(flex: 2),
          const LanguageToggleButton(),
        ],
      ),
    );
  }
}
