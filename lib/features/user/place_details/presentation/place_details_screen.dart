import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/user/place_details/cubit/place_details_cubit.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/details_glass_button.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/place_description_widget.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/place_image_carousel.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/subplaces_list_widget.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/text_details_wdiget.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';

import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final PlaceModel place;

  const PlaceDetailsScreen({super.key, required this.place});

  void _sharePlace(BuildContext context, PlaceModel place) {
    Clipboard.setData(ClipboardData(text: place.locationUrl.isEmpty ? place.name : place.locationUrl));
    SnackBarUtils.showSuccess(context, 'linkCopied');
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final imageHeight = h * 0.4;
    final topPadding = MediaQuery.of(context).padding.top + 10;

    return BlocProvider(
      create: (context) => PlaceDetailsCubit(place),
      child: Scaffold(
        backgroundColor: ColorManager.noirDeVigne,
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
                // 1. Background basic style
                BackGround(h: h, w: w, category: livePlace.type),

                // 2. Image Carousel Slider
                PlaceImageCarousel(images: livePlace.images.cast<String>(), height: imageHeight),

                // 3. Scrollable Details Sheet
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: imageHeight - 20),

                      Container(
                        decoration: BoxDecoration(
                          color: ColorManager.cardSurface.withOpacity(0.9),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                          border: const Border(
                            top: BorderSide(
                              color: ColorManager.emeraldGreen,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            TextDetailsWidget(w: w, place: livePlace, h: h),
                            PlaceDescriptionWidget(description: livePlace.description, w: w, h: h),
                             FutureBuilder<List<SubPlaceModel>>(
                              future: getIt<AdminService>().getSubPlacesByIds(livePlace.subPlacesIds),
                              builder: (context, subPlacesSnapshot) {
                                if (!subPlacesSnapshot.hasData) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(
                                        color: ColorManager.wasabi,
                                      ),
                                    ),
                                  );
                                }
                                final subPlaces = subPlacesSnapshot.data!;
                                return SubPlacesListWidget(
                                  place: livePlace,
                                  subPlaces: subPlaces,
                                  w: w,
                                  h: h,
                                );
                              },
                            ),
                            SizedBox(height: h * 0.05),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Back button
                Positioned(
                  top: topPadding,
                  left: 15,
                  child: DetailsGlassButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                // 5. Share button
                Positioned(
                  top: topPadding,
                  right: 15,
                  child: DetailsGlassButton(
                    icon: Icons.share_rounded,
                    onTap: () => _sharePlace(context, livePlace),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
