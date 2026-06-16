import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class PlaceCategoryChip extends StatelessWidget {
  final String type;
  final double w;

  const PlaceCategoryChip({
    super.key,
    required this.type,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type.toLowerCase()) {
      case 'football':
        icon = Icons.sports_soccer;
        break;
      case 'padel':
        icon = Icons.sports_tennis;
        break;
      case 'playstation':
        icon = Icons.sports_esports;
        break;
      case 'cafe':
        icon = Icons.coffee;
        break;
      default:
        icon = Icons.grid_view_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorManager.wasabi.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorManager.wasabi.withOpacity(0.4),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: w * 0.038, color: ColorManager.wasabi),
          const SizedBox(width: 4),
          Text(
            context.tr(type),
            style: TextStyle(
              color: ColorManager.creasedKhaki,
              fontSize: w * 0.032,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
