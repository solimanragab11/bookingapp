import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class TextDetailsWidget extends StatelessWidget {
  const TextDetailsWidget({
    super.key,
    required this.w,
    required this.place,
    required this.h,
  });

  final double w;
  final Place place;
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
              color: ColorManager.cardSurface.withOpacity(
                0.2,
              ), // خلفية شفافة جداً
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Name and Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: TextStyle(
                          fontSize: w * 0.065,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildRatingBadge(place.rating, w),
                  ],
                ),

                const SizedBox(height: 15),

                // 2. Minimum Charge (if no subplaces)
                if (place.subPlaces.isEmpty) ...[
                  _buildInfoRow(
                    Icons.payments_outlined,
                    '${context.tr('minimumCharge')}: ${place.minimumCharge?.toStringAsFixed(0) ?? "-"} ${context.tr('le')}',
                    ColorManager.wasabi,
                    w,
                  ),
                  const SizedBox(height: 12),
                ],

                // 3. Location info
                _buildInfoRow(
                  Icons.location_on_outlined,
                  "${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}",
                  Colors.redAccent,
                  w,
                ),

                const SizedBox(height: 12),

                // 4. Opening Hours
                _buildInfoRow(
                  Icons.access_time_rounded,
                  '${context.tr('open')}: ${place.openingTime} → ${place.closingTime}',
                  Colors.white70,
                  w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت صغيرة للـ Rating بشكل شيك
  Widget _buildRatingBadge(double rating, double w) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: w * 0.05),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: w * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت موحدة لصفوف المعلومات
  Widget _buildInfoRow(IconData icon, String text, Color iconColor, double w) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: w * 0.055),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: w * 0.038,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
