import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class SubPlaceInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const SubPlaceInfoItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(icon, size: w * 0.045, color: ColorManager.wasabi),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: w * 0.035),
        ),
      ],
    );
  }
}
