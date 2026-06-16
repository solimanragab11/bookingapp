import 'package:flutter/material.dart';

class PlaceInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final double w;

  const PlaceInfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: w * 0.055),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: w * 0.038,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
