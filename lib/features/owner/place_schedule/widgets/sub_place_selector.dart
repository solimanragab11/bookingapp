import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class SubPlaceSelector extends StatelessWidget {
  final int count;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const SubPlaceSelector({
    super.key,
    required this.count,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: count,
        itemBuilder: (_, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorManager.egyptianEarth
                    : ColorManager.cardSurface.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? ColorManager.egyptianEarth
                      : ColorManager.emeraldGreen.withOpacity(0.2),
                  width: 1.2,
                ),
              ),
              child: Text(
                '${context.tr('field_label', defaultValue: 'Field')} ${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
