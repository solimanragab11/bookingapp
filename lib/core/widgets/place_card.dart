import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // المكتبة المطلوبة لفتح الخرائط
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onPressed;
  final bool isAvailable;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onPressed,
    required this.isAvailable,
  });

  // دالة لفتح جوجل مابز بالإحداثيات
  Future<void> _openMap() async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${place.latitude},${place.longitude}";
    final Uri url = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $googleMapsUrl");
      }
    } catch (e) {
      debugPrint("Error opening map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final subPlace = place.subPlaces.isNotEmpty ? place.subPlaces[0] : null;
    final price = subPlace?.pricePerHour.toStringAsFixed(0) ?? "N/A";
    final players = subPlace?.playersNumber ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: h * 0.025),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: ColorManager.cardSurface.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Section
                SizedBox(
                  height: h * 0.22,
                  width: double.infinity,
                  child: place.images.isNotEmpty
                      ? Image.network(
                          place.images[0],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[900],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                          ),
                        ),
                ),

                // 2. Content Section
                Padding(
                  padding: EdgeInsets.all(w * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              place.name,
                              style: TextStyle(
                                fontSize: w * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(context, isAvailable),
                        ],
                      ),

                      const Divider(color: Colors.white12, height: 20),

                      // Price & Players
                      Row(
                        children: [
                          _buildIconInfo(
                            Icons.payments_outlined,
                            "$price ${context.tr('currency', defaultValue: 'EGP')}/hr",
                            w,
                          ),
                          SizedBox(width: w * 0.05),
                          _buildIconInfo(
                            Icons.groups_outlined,
                            "$players Vs $players",
                            w,
                          ),
                        ],
                      ),

                      SizedBox(height: h * 0.015),

                      // --- Location Clickable Section ---
                      GestureDetector(
                        onTap: _openMap, // يفتح الخريطة عند الضغط
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: ColorManager.wasabi,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                place.locationUrl.isEmpty
                                    ? context.tr('viewOnMap')
                                    : place.locationUrl,
                                style: TextStyle(
                                  color: Colors.blueAccent, // لون اللينك
                                  fontSize: w * 0.032,
                                  decoration:
                                      TextDecoration.underline, // خط تحت الكلام
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.02),

                      // Action Button
                      Center(
                        child: CustButton(
                          h: h,
                          w: w,
                          color: ColorManager.wasabi,
                          onTap: onPressed,
                          size: "mid",
                          lable: context.tr(
                            'placeDetails',
                            defaultValue: 'Place Details',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool available) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (available ? Colors.green : Colors.red).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: available ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Text(
        available ? context.tr('available') : context.tr('unavailable'),
        style: TextStyle(
          color: available ? Colors.greenAccent : Colors.redAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String label, double w) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: w * 0.035),
        ),
      ],
    );
  }
}
