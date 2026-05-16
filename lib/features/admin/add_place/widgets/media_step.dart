import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class MediaStep extends StatelessWidget {
  // غيرنا النوع لـ dynamic عشان يشيل الـ String (الـ URL القديم) والـ File (الصور الجديدة) سوا
  final List<dynamic> mainImages;
  final Future<void> Function() onAddImages;
  final ValueChanged<int> onRemoveImage;

  const MediaStep({
    super.key,
    required this.mainImages,
    required this.onAddImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: size.width > 600 ? 4 : 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: mainImages.length + 1,
          itemBuilder: (context, index) {
            if (index == mainImages.length) {
              return _buildAddImageButton();
            }
            return _buildImageItem(index);
          },
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: onAddImages,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorManager.wasabi.withOpacity(0.5)),
        ),
        child: const Icon(Icons.add_a_photo, color: ColorManager.wasabi),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    final imageSource = mainImages[index];

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImageWidget(imageSource),
          ),
        ),
        Positioned(
          right: 5,
          top: 5,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ويدجت ذكية تفصل وتحدد طريقة العرض حسب نوع الداتا المتخزنة
  Widget _buildImageWidget(dynamic source) {
    if (source is File) {
      // لو صورة جديدة الأدمن لسه مختارها من الجهاز
      return Image.file(source, fit: BoxFit.cover);
    } else if (source is String) {
      // لو رابط قديم جاي من Firebase في حالة الـ Edit
      if (source.startsWith('http') || source.startsWith('https')) {
        return CachedNetworkImage(
          imageUrl: source,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.white.withOpacity(0.05),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ColorManager.wasabi,
                  ),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.white.withOpacity(0.05),
            child: const Icon(
              Icons.broken_image,
              color: Colors.redAccent,
              size: 20,
            ),
          ),
        );
      } else {
        // لو مسار محلي متسيف كـ String
        return Image.file(File(source), fit: BoxFit.cover);
      }
    }
    return const Icon(Icons.broken_image, color: Colors.redAccent);
  }
}
