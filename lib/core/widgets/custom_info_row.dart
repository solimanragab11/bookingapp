import 'package:flutter/material.dart';

class CustomInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? labelColor;

  const CustomInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: labelColor ?? Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
