import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';

class SubPlaceCard extends StatelessWidget {
  final PlaceModel place;
  final SubPlace subPlace;
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
        color: ColorManager.cardSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. صورة الملعب الفرعي
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  subPlace.imageUrl,
                  height: h * 0.18,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: h * 0.18,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              // تاغ متاح / غير متاح
              Positioned(
                top: 12,
                right: 12,
                child: _buildAvailabilityBadge(context, isAvailable),
              ),
            ],
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
                    _buildInfoItem(
                      Icons.payments_outlined,
                      "${subPlace.pricePerHour.toStringAsFixed(0)} ${context.tr('le')}",
                      w,
                    ),
                    const SizedBox(width: 15),
                    _buildInfoItem(
                      Icons.groups_outlined,
                      "${subPlace.playersNumber} Vs ${subPlace.playersNumber}",
                      w,
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
                      backgroundColor: ColorManager.wasabi,
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

  Widget _buildAvailabilityBadge(BuildContext context, bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: available
            ? Colors.green.withOpacity(0.9)
            : Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        available ? context.tr('available') : context.tr('unavailable'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, double w) {
    return Row(
      children: [
        Icon(icon, size: w * 0.045, color: ColorManager.wasabi),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: w * 0.035),
        ),
      ],
    );
  }
}
