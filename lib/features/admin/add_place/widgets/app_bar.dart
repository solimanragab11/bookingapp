import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/lang_button.dart';

class CustAppBar extends StatelessWidget {
  const CustAppBar({super.key, required this.width, required this.onTap});
  final double width;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: ColorManager.wasabi),
          ),
          const Spacer(),
          Text(
            context.tr('addNewPlace'),
            style: TextStyle(
              color: ColorManager.wasabi,
              fontSize: width * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.delete_forever, color: Colors.red),
          ),
          const Spacer(flex: 2),
          const LanguageToggleButton(),
        ],
      ),
    );
  }
}
