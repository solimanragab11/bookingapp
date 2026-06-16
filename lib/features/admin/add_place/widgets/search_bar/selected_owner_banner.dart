import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class SelectedOwnerBanner extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onCancel;

  const SelectedOwnerBanner({
    super.key,
    required this.name,
    required this.phone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ColorManager.wasabi.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorManager.wasabi.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: ColorManager.wasabi, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: ColorManager.wasabi,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.close, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('cancel'),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
