import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class AnalysisItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const AnalysisItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: ColorManager.creasedKhaki,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
