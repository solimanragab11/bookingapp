import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

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
        color: isOfferEnabled
            ? ColorManager.wasabi.withOpacity(0.08)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOfferEnabled ? ColorManager.wasabi : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: isOfferEnabled ? ColorManager.wasabi : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Localization: استخدام النقاط
                    Text(
                      "${context.tr('usePoints')} ($userPoints)",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (!isOfferEnabled)
                      Text(
                        context.tr(
                          'activateDiscountHint',
                        ), // رسالة: فعل الخصم للحصول على تخفيض
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Switch(
                value: isOfferEnabled,
                activeColor: ColorManager.wasabi,
                onChanged: (val) {
                  onToggleChanged(val);
                },
              ),
            ],
          ),
          if (isOfferEnabled) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${context.tr('using')} $selectedPoints ${context.tr('points')}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
              activeColor: ColorManager.wasabi,
              inactiveColor: ColorManager.wasabi.withOpacity(0.2),
              onChanged: onSliderChanged,
            ),
          ],
        ],
      ),
    );
  }
}
