import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class CategoryCard extends StatelessWidget {
  final String categoryId;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.categoryId,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 50,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorManager.egyptianEarth.withOpacity(0.15)
              : ColorManager.cardSurface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? ColorManager.egyptianEarth
                : ColorManager.emeraldGreen.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: isSelected
                  ? ColorManager.egyptianEarth
                  : ColorManager.creasedKhaki.withOpacity(0.6),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr(categoryId),
              style: TextStyle(
                color: isSelected
                    ? ColorManager.egyptianEarth
                    : ColorManager.creasedKhaki.withOpacity(0.7),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
