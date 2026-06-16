import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class SubPlaceImage extends StatelessWidget {
  final String imageUrl;
  final bool isAvailable;

  const SubPlaceImage({
    super.key,
    required this.imageUrl,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                height: h * 0.18,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: h * 0.18,
                  width: double.infinity,
                  color: ColorManager.noirDeVigne,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorManager.egyptianEarth,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: h * 0.18,
                  width: double.infinity,
                  color: ColorManager.noirDeVigne,
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.white54,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _buildAvailabilityBadge(context, isAvailable),
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge(BuildContext context, bool available) {
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
}
