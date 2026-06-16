import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;
  final double letterSpacing;

  const BrandLogo({
    super.key,
    required this.fontSize,
    this.letterSpacing = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: RichText(
        text: TextSpan(
          style: TextStyleMangare.headingStyle.copyWith(
            fontSize: fontSize,
            letterSpacing: letterSpacing,
          ),
          children: [
            TextSpan(
              text: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'هنظبط'
                  : 'Hanz',
              style: const TextStyle(color: Colors.white),
            ),
            TextSpan(
              text: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'هالك'
                  : 'bthalk',
              style: const TextStyle(color: ColorManager.egyptianEarth),
            ),
          ],
        ),
      ),
    );
  }
}
