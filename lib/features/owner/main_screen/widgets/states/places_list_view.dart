import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/features/owner/main_screen/widgets/place_card_owner.dart';

class PlacesListView extends StatelessWidget {
  final List<PlaceModel> places;

  const PlacesListView({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        return PlaceCardOwner(place: places[index]);
      },
    );
  }
}
