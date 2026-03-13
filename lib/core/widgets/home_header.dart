import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';
import 'package:remaking_booking_app_trail2/core/widgets/lang_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // فتح الـ Drawer عند الضغط على أيقونة المنيو (بديل للأيقونات الكتيرة)
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: ColorManager.wasabi,
              size: w * 0.08,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),

          Text(
            context.tr('appName'),
            style: TextStyleMangare.headingStyle.copyWith(
              fontSize: w * 0.065,
              color: ColorManager.wasabi,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          // زرار اللغة الزجاجي
          const LanguageToggleButton(),
        ],
      ),
    );
  }
}
