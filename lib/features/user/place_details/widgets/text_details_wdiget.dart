import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/place_category_chip.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/place_info_row.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/place_location_row.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/place_open_status_badge.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/place_rating_badge.dart';

class TextDetailsWidget extends StatelessWidget {
  const TextDetailsWidget({
    super.key,
    required this.w,
    required this.place,
    required this.h,
  });

  final double w;
  final PlaceModel place;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.01),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(w * 0.05),
            decoration: BoxDecoration(
              color: ColorManager.cardSurface.withOpacity(0.6), // خلفية شفافة
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: ColorManager.emeraldGreen, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Name, Category, and Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: TextStyle(
                              fontSize: w * 0.065,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          PlaceCategoryChip(type: place.type, w: w),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    PlaceRatingBadge(rating: place.rating, w: w),
                  ],
                ),

                const SizedBox(height: 15),

                // 2. Minimum Charge (if no subplaces)
                if (place.subPlacesIds.isEmpty) ...[
                  PlaceInfoRow(
                    icon: Icons.payments_outlined,
                    text: '${context.tr('minimumCharge')}: ${place.minimumCharge?.toStringAsFixed(0) ?? "-"} ${context.tr('le')}',
                    iconColor: ColorManager.wasabi,
                    w: w,
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Location info (Clickable Link)
                PlaceLocationRow(
                  icon: Icons.location_on_outlined,
                  text: place.locationUrl.isEmpty
                      ? context.tr('viewOnMap')
                      : place.locationUrl,
                  iconColor: ColorManager.wasabi,
                  w: w,
                  locationUrl: place.locationUrl,
                  latitude: place.latitude,
                  longitude: place.longitude,
                ),

                const SizedBox(height: 12),

                // 4. Opening Hours
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: ColorManager.creasedKhaki, size: w * 0.055),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            '${context.tr('open')}: ${place.openingTime} → ${place.closingTime}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: w * 0.038,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          PlaceOpenStatusBadge(
                            openingTime: place.openingTime,
                            closingTime: place.closingTime,
                            w: w,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
