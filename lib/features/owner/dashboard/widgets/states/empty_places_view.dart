import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class EmptyPlacesView extends StatelessWidget {
  const EmptyPlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.storefront_outlined,
            size: 80,
            color: ColorManager.creasedKhaki,
          ),
          SizedBox(height: 16),
          Text(
            "مفيش أماكن متضافة لسه يا وحش!",
            style: TextStyle(
              color: ColorManager.creasedKhaki,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

