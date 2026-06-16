import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class EmptyPlacesView extends StatelessWidget {
  const EmptyPlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 80,
            color: ColorManager.creasedKhaki,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('noPlacesFound'),
            style: const TextStyle(
              color: ColorManager.creasedKhaki,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
