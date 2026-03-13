import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/features/user/place_details/cubit/place_details_cubit.dart';

import 'package:remaking_booking_app_trail2/features/user/place_details/widgets/subplace_card.dart';
import 'package:remaking_booking_app_trail2/features/user/place_details/widgets/text_details_wdiget.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocProvider(
      // بنكريت الـ Cubit وبنديله الـ place اللي جاي لنا
      create: (context) => PlaceDetailsCubit(place),
      child: Scaffold(
        body: Stack(
          children: [
            BackGround(h: h, w: w),
            // استخدام CustomScrollView عشان الـ Slivers
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. الجزء اللي فوق (الصورة اللي بتختفي)
                _buildSliverAppBar(h, w, place),

                // 2. محتوى الصفحة
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: h * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextDetailsWidget(w: w, place: place, h: h),
                        _buildSectionTitle(context, 'about', w),
                        _buildDescription(place.description, w, h),
                        _buildSectionTitle(context, 'availableFields', w),
                        _buildSubPlacesList(w, h, place),
                        SizedBox(height: h * 0.05), // مساحة أمان تحت
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت الـ AppBar المتطور
  Widget _buildSliverAppBar(double h, double w, Place place) {
    return SliverAppBar(
      expandedHeight: h * 0.35,
      pinned: true, // يفضل موجود فوق لما تعمل Scroll
      backgroundColor: ColorManager.wasabi,
      flexibleSpace: FlexibleSpaceBar(
        background: CarouselSlider(
          items: place.images.map((imageUrl) {
            return Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.white),
            );
          }).toList(),
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            autoPlay: true,
            enlargeCenterPage: false,
          ),
        ),
      ),
    );
  }

  // ويدجت العناوين
  Widget _buildSectionTitle(BuildContext context, String key, double w) {
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.06, w * 0.05, w * 0.02),
      child: Text(
        context.tr(key),
        style: TextStyle(
          fontSize: w * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.white, // عشان يمشي مع الـ Dark Background بتاعك
        ),
      ),
    );
  }

  // ويدجت الوصف
  Widget _buildDescription(String desc, double w, double h) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
      child: Text(
        desc,
        style: TextStyle(
          height: 1.6,
          fontSize: w * 0.038,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  // ويدجت قائمة الملاعب الفرعية
  Widget _buildSubPlacesList(double w, double h, Place place) {
    return ListView.builder(
      shrinkWrap: true, // مهم جداً جوه الـ ScrollView
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
      itemCount: place.subPlaces.length,
      itemBuilder: (context, index) {
        final subPlace = place.subPlaces[index];
        return SubPlaceCard(
          place: place,
          subPlace: subPlace,
          onPressed: () => Navigator.pushNamed(
            context,
            Routes.bookingPage,
            arguments: {'place': place, 'subPlace': subPlace},
          ),
          isAvailable: subPlace.freeTimeSlots.values.any(
            (list) => list.isNotEmpty,
          ),
        );
      },
    );
  }
}
