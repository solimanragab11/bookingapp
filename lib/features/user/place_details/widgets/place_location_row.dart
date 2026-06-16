import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';

class PlaceLocationRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final double w;
  final String locationUrl;
  final double latitude;
  final double longitude;

  const PlaceLocationRow({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.w,
    required this.locationUrl,
    required this.latitude,
    required this.longitude,
  });

  Future<void> _openMap() async {
    final String urlString = locationUrl.isNotEmpty && locationUrl.startsWith('http')
        ? locationUrl
        : "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    final Uri url = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $urlString");
      }
    } catch (e) {
      debugPrint("Error opening map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openMap,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: w * 0.055),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.isEmpty ? context.tr('viewOnMap') : text,
              style: const TextStyle(
                color: Colors.blueAccent, // لون رابط قابل للنقر
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
