import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class DetailsGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const DetailsGlassButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorManager.cardSurface.withOpacity(0.5),
            border: Border.all(
              color: ColorManager.emeraldGreen,
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: onTap,
              child: Center(
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
