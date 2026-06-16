import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class AdminHeader extends StatelessWidget {
  final bool isTablet;
  final String userName;
  const AdminHeader({
    super.key,
    required this.isTablet,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${context.tr('Welcome')},",
                style: TextStyle(
                  color: ColorManager.cardSurface,
                  fontSize: isTablet ? 18 : 14,
                ),
              ),
              Text(
                userName, // تم إضافة localization للاسم لو حبيت
                style: TextStyle(
                  color: ColorManager.cardSurface,
                  fontSize: isTablet ? 28 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
