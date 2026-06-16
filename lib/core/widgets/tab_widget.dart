import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:flutter/material.dart';

class TabWidget extends StatelessWidget {
  const TabWidget({
    super.key,
    required this.width,
    required this.height,
    required this.tabName,
    required this.isSelected,
    required this.ontap,
  });
  final double width;
  final double height;
  final String tabName;
  final VoidCallback ontap;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Column(
        children: [
          Text(
            tabName,
            style: TextStyle(
              fontSize: width * 0.03, // Converted from hardcoded font size
              color: isSelected
                  ? ColorManager.egyptianEarth
                  : ColorManager.wasabi,
            ),
          ),
          Container(
            width: width * 0.44,
            height: height * 0.004,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(width * 0.02),
              color: isSelected
                  ? ColorManager.egyptianEarth
                  : ColorManager.wasabi,
            ),
          ),
        ],
      ),
    );
  }
}
