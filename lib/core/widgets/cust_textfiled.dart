import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class CustTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPhone;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Color? textColor;
  final Color? iconColor;

  const CustTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPhone = false,
    this.isPassword = false,
    this.validator,
    this.textColor = Colors.black, // اللون الافتراضي للنص
    this.iconColor = ColorManager.wasabi, // اللون الافتراضي للأيقونة
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: isPassword, // عشان لو حبيت تستخدمها للباسورد
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      inputFormatters: isPhone
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ]
          : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: iconColor),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        // تعديل الـ Border ليكون متناسق مع تصميم الـ Login
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ColorManager.wasabi, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
