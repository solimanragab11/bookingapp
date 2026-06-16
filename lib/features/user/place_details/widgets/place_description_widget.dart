import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';

class PlaceDescriptionWidget extends StatelessWidget {
  final String description;
  final double w;
  final double h;

  const PlaceDescriptionWidget({
    super.key,
    required this.description,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.06, w * 0.05, w * 0.02),
          child: Text(
            context.tr('about'),
            style: TextStyle(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          child: Text(
            description,
            style: TextStyle(
              height: 1.6,
              fontSize: w * 0.038,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
