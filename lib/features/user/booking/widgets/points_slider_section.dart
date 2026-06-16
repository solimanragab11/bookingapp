import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class PointsSliderSection extends StatelessWidget {
  final int userPoints;
  final bool isOfferEnabled;
  final int selectedPoints;
  final double maxPointsLimit;
  final ValueChanged<bool> onToggleChanged;
  final ValueChanged<double> onSliderChanged;

  const PointsSliderSection({
    super.key,
    required this.userPoints,
    required this.isOfferEnabled,
    required this.selectedPoints,
    required this.maxPointsLimit,
    required this.onToggleChanged,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorManager.noirDeVigne.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOfferEnabled
              ? ColorManager.egyptianEarth
              : ColorManager.emeraldGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.stars_rounded,
                color: ColorManager.egyptianEarth,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${context.tr('usePoints')} ($userPoints)",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    if (!isOfferEnabled)
                      Text(
                        context.tr('activateDiscountHint'),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: isOfferEnabled,
                activeColor: ColorManager.egyptianEarth,
                activeTrackColor: ColorManager.egyptianEarth.withOpacity(0.4),
                onChanged: (val) {
                  onToggleChanged(val);
                },
              ),
            ],
          ),
          if (isOfferEnabled) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1, color: Colors.white12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${context.tr('using')} $selectedPoints ${context.tr('points')}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                Text(
                  "${context.tr('discount')} $selectedPoints%",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Slider(
              value: selectedPoints.toDouble(),
              min: 0,
              max: maxPointsLimit,
              divisions: maxPointsLimit.toInt() > 0
                  ? maxPointsLimit.toInt()
                  : 1,
              activeColor: ColorManager.egyptianEarth,
              inactiveColor: ColorManager.egyptianEarth.withOpacity(0.2),
              onChanged: onSliderChanged,
            ),
          ],
        ],
      ),
    );
  }
}
