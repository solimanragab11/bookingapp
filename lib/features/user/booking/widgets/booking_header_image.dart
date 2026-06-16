import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class BookingHeaderImage extends StatelessWidget {
  final String imageUrl;
  final double height;

  const BookingHeaderImage({
    super.key,
    required this.imageUrl,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        // مؤشر تحميل ناعم ومتناسق أثناء نزول الصورة لأول مرة
        placeholder: (context, url) => Container(
          height: height,
          width: double.infinity,
          color: ColorManager.noirDeVigne,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ColorManager.egyptianEarth),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: height,
          width: double.infinity,
          color: ColorManager.noirDeVigne,
          child: const Icon(Icons.broken_image, color: ColorManager.egyptianEarth),
        ),
      ),
    );
  }
}
