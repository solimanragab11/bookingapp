import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class CustTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPhone;
  final bool isPassword;
  final String? Function(String?)? validator;
  final Color? textColor;
  final Color? iconColor;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? hintTextColor;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

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
    this.fillColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.hintTextColor,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  _CustTextFieldState createState() => _CustTextFieldState();
}

// ignore: library_private_types_in_public_api
class _CustTextFieldState extends State<CustTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscure,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType ?? (widget.isPhone ? TextInputType.phone : TextInputType.text),
      style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w500),
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters ?? (widget.isPhone
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ]
          : null),
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: widget.iconColor),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
        hintText: widget.hint,
        hintStyle: TextStyle(color: widget.hintTextColor ?? Colors.grey.withOpacity(0.7)),
        filled: true,
        fillColor: widget.fillColor ?? Colors.white.withOpacity(0.9),
        counterText: widget.maxLength != null ? "" : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: widget.enabledBorderColor != null
              ? BorderSide(color: widget.enabledBorderColor!, width: 1.0)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: widget.enabledBorderColor != null
              ? BorderSide(color: widget.enabledBorderColor!, width: 1.0)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? ColorManager.wasabi,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
