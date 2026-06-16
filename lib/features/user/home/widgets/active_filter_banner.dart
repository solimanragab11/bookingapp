import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class ActiveFilterBanner extends StatelessWidget {
  final String summary;
  final VoidCallback onClear;

  const ActiveFilterBanner({
    super.key,
    required this.summary,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorManager.egyptianEarth.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.filter_alt_rounded,
            color: ColorManager.egyptianEarth,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('smartFilterActiveTitle'),
                style: TextStyle(
                  color: ColorManager.egyptianEarth,
                  fontWeight: FontWeight.bold,
                  fontSize: w * 0.035,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                summary,
                style: TextStyle(color: Colors.white70, fontSize: w * 0.026),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
