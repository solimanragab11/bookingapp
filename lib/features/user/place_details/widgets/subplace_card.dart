import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/subplace_image.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/subplace_info_item.dart';

class SubPlaceCard extends StatelessWidget {
  final PlaceModel place;
  final SubPlaceModel subPlace;
  final VoidCallback onPressed;
  final bool isAvailable;

  const SubPlaceCard({
    super.key,
    required this.place,
    required this.subPlace,
    required this.onPressed,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(vertical: h * 0.01),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorManager.emeraldGreen, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. صورة الملعب الفرعي وتاغ الحالة
          SubPlaceImage(
            imageUrl: subPlace.imageUrl,
            isAvailable: isAvailable,
          ),

          // 2. تفاصيل الملعب
          Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subPlace.id, // أو subPlace.name لو موجود
                  style: TextStyle(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SubPlaceInfoItem(
                      icon: Icons.payments_outlined,
                      label: "${subPlace.pricePerHour.toStringAsFixed(0)} ${context.tr('le')}",
                    ),
                    const SizedBox(width: 15),
                    SubPlaceInfoItem(
                      icon: Icons.groups_outlined,
                      label: "${subPlace.playersNumber} Vs ${subPlace.playersNumber}",
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // 3. زرار الحجز
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.egyptianEarth,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.tr('bookNow', defaultValue: 'Book Now'),
                      style: TextStyleMangare.headingStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
