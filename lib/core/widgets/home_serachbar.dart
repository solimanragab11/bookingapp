import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.onChanged});
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorManager.wasabi.withOpacity(0.2)),
      ),
      child: TextField(
        onChanged: onChanged,
        // تم تعديل لون الخط ليكون أبيض ليناسب الخلفية الغامقة
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: context.tr('search'),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: const Icon(Icons.search, color: ColorManager.wasabi),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
