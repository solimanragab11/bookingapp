import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final PlaceModel place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final imageHeight = h * 0.4; // ارتفاع الصورة الثابتة

    return BlocProvider(
      create: (context) => PlaceDetailsCubit(place),
      child: Scaffold(
        backgroundColor: Colors.black, // أو أي لون أساسي عندك
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('places')
              .doc(place.id)
              .snapshots(),
          builder: (context, snapshot) {
            PlaceModel livePlace = place;
            if (snapshot.hasData && snapshot.data!.exists) {
              livePlace = PlaceModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>,
              );
            }

            return Stack(
              children: [
                // 1. الخلفية الأساسية للتطبيق
                BackGround(h: h, w: w),

                // 2. الجزء الثابت (الصور)
                SizedBox(
                  height: imageHeight,
                  width: w,
                  child: CarouselSlider(
                    items: livePlace.images.map((imageUrl) {
                      return Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.white),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: imageHeight,
                      viewportFraction: 1.0,
                      autoPlay: true,
                    ),
                  ),
                ),

                // 3. المحتوى القابل للتمرير
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // مساحة شفافة بارتفاع الصورة عشان الكلام ميبدأش من فوقها
                      SizedBox(height: imageHeight),

                      // الحاوية اللي هتشيل البيانات وتغطي الصورة وهي طالعة
                      Container(
                        decoration: BoxDecoration(
                          color: ColorManager.cardSurface.withOpacity(
                            0.9,
                          ), // لون الخلفية اللي هيغطي الصورة
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            TextDetailsWidget(w: w, place: livePlace, h: h),
                            _buildSectionTitle(context, 'about', w),
                            _buildDescription(livePlace.description, w, h),
                            _buildSectionTitle(context, 'availableFields', w),
                            _buildSubPlacesList(w, h, livePlace),
                            SizedBox(height: h * 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. زرار الرجوع (لأنه اختفى مع الـ SliverAppBar)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- باقي الـ Widgets كما هي في كودك الأصلي ---

  Widget _buildSectionTitle(BuildContext context, String key, double w) {
    return Padding(
      padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.06, w * 0.05, w * 0.02),
      child: Text(
        context.tr(key),
        style: TextStyle(
          fontSize: w * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

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

  Widget _buildSubPlacesList(double w, double h, PlaceModel livePlace) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: w * 0.05),
      itemCount: livePlace.subPlaces.length,
      itemBuilder: (context, index) {
        final subPlace = livePlace.subPlaces[index];
        return SubPlaceCard(
          place: livePlace,
          subPlace: subPlace,
          onPressed: () {
            Navigator.pushNamed(
              context,
              Routes.bookingPage,
              arguments: {'place': livePlace, 'subPlace': subPlace},
            );
          },
          isAvailable: subPlace.freeTimeSlots.values.any(
            (list) => list.isNotEmpty,
          ),
        );
      },
    );
  }
}
