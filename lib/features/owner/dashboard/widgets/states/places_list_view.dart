import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/place_card.dart';

class PlacesListView extends StatelessWidget {
  final List<PlaceModel> places;

  const PlacesListView({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        return PlaceCard(place: places[index]);
      },
    );
  }
}
