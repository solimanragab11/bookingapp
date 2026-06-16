import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class QuickActionButton extends StatelessWidget {
  final String label;
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorManager.egyptianEarth
                : ColorManager.noirDeVigne.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? ColorManager.egyptianEarth
                  : ColorManager.emeraldGreen.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                "${amount.toStringAsFixed(0)} ${context.tr('egp')}",
                style: TextStyle(
                  color: isSelected ? Colors.white : ColorManager.wasabi,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
