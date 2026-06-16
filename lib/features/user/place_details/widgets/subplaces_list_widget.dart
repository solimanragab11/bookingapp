import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/features/user/place_details/widgets/subplace_card.dart';

class SubPlacesListWidget extends StatelessWidget {
  final PlaceModel place;
  final List<SubPlaceModel> subPlaces;
  final double w;
  final double h;

  const SubPlacesListWidget({
    super.key,
    required this.place,
    required this.subPlaces,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(w * 0.05, w * 0.06, w * 0.05, w * 0.02),
          child: Text(
            context.tr('availableFields'),
            style: TextStyle(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: w * 0.05),
          itemCount: subPlaces.length,
          itemBuilder: (context, index) {
            final subPlace = subPlaces[index];
            return SubPlaceCard(
              place: place,
              subPlace: subPlace,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  Routes.bookingPage,
                  arguments: {'place': place, 'subPlace': subPlace},
                );
              },
              isAvailable: subPlace.slotsIds.isNotEmpty,
            );
          },
        ),
      ],
    );
  }
}
