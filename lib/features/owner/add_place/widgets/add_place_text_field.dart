import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class AddPlaceTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final bool isNumber;

  const AddPlaceTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.maxLines = 1,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: ColorManager.creasedKhaki),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: ColorManager.wasabi),
        prefixIcon: Icon(icon, color: ColorManager.egyptianEarth),
        filled: true,
        fillColor: ColorManager.cardSurface.withOpacity(0.8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ColorManager.emeraldGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: ColorManager.egyptianEarth,
            width: 2,
          ),
        ),
      ),
    );
  }
}
