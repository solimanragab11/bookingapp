import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_analytics_service.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class PlacesBreakdown extends StatelessWidget {
  const PlacesBreakdown({super.key, required this.places});
  final List<PlaceReport> places;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "مقارنة أداء الملاعب",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.cardSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ColorManager.wasabi.withOpacity(0.1),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(color: ColorManager.wasabi),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: ${place.placeName}",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "${place.bookingCount} حجز هذا الشهر",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${place.revenue.toInt()} EGP",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
