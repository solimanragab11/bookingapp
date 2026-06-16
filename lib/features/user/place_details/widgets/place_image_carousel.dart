import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class PlaceImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;

  const PlaceImageCarousel({
    super.key,
    required this.images,
    required this.height,
  });

  @override
  State<PlaceImageCarousel> createState() => _PlaceImageCarouselState();
}

class _PlaceImageCarouselState extends State<PlaceImageCarousel> {
  final ValueNotifier<int> _currentImageIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _currentImageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          width: w,
          child: CarouselSlider(
            items: widget.images.map((imageUrl) {
              return CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
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
                  width: double.infinity,
                  color: ColorManager.noirDeVigne,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: widget.height,
              viewportFraction: 1.0,
              autoPlay: true,
              onPageChanged: (index, reason) {
                _currentImageIndex.value = index;
              },
            ),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _currentImageIndex,
              builder: (context, activeIndex, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.images.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: activeIndex == index ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: activeIndex == index
                            ? ColorManager.egyptianEarth
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
