import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class BackGround extends StatelessWidget {
  const BackGround({super.key, required this.h, required this.w});

  final double h;
  final double w;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: ColorManager.cardSurface),
        Container(
          height: h * 0.385,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(w * 0.15),
              bottomRight: Radius.circular(w * 0.15),
            ),
          ),
        ),
      ],
    );
  }
}
