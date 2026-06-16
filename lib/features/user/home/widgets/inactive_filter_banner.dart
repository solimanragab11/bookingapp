import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:shimmer/shimmer.dart';

class InactiveFilterBanner extends StatelessWidget {
  const InactiveFilterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorManager.egyptianEarth.withOpacity(0.2),
                ColorManager.egyptianEarth.withOpacity(0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Shimmer.fromColors(
            baseColor: ColorManager.egyptianEarth,
            highlightColor: ColorManager.creasedKhaki,
            period: const Duration(milliseconds: 2500),
            child: const Icon(
              Icons.bolt_rounded,
              color: ColorManager.egyptianEarth,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: ColorManager.creasedKhaki,
                highlightColor: Colors.white,
                period: const Duration(milliseconds: 3000),
                child: Text(
                  context.tr('catchyFilterTitle'),
                  style: TextStyle(
                    color: ColorManager.creasedKhaki,
                    fontWeight: FontWeight.w800,
                    fontSize: w * 0.038,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('catchyFilterSubtitle'),
                style: TextStyle(color: Colors.white60, fontSize: w * 0.028),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColorManager.egyptianEarth.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ColorManager.egyptianEarth.withOpacity(0.4),
            ),
          ),
          child: Text(
            context.tr('tryItBtn', defaultValue: 'Try it!'),
            style: TextStyle(
              color: ColorManager.egyptianEarth,
              fontWeight: FontWeight.bold,
              fontSize: w * 0.03,
            ),
          ),
        ),
      ],
    );
  }
}
