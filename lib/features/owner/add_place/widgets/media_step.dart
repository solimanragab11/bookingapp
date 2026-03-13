import 'dart:io';

import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class MediaStep extends StatelessWidget {
  final List<File> mainImages;
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
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            mainImages[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
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
}

