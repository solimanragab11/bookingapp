import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/map_selection_screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/add_place_text_field.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/sub_places_list_section.dart.dart';

class SubPlacesStep extends StatelessWidget {
  final String? selectedCategory;
  final TextEditingController minChargeController;
  final List<Map<String, dynamic>> subPlaces;
  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;
  final VoidCallback onAddSubPlace;
  final ValueChanged<int> onRemoveSubPlace;
  final Future<void> Function(int) onPickImage;

  const SubPlacesStep({
    super.key,
    required this.selectedCategory,
    required this.minChargeController,
    required this.subPlaces,
    required this.selectedLocation,
    required this.onLocationSelected,
    required this.onAddSubPlace,
    required this.onRemoveSubPlace,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        if (selectedCategory == context.tr('Cafe'))
          AddPlaceTextField(
            label: context.tr('minimumCharge'),
            controller: minChargeController,
            icon: Icons.payments,
            isNumber: true,
          ),
        SubPlacesListSection(
          subPlaces: subPlaces,
          onAdd: onAddSubPlace,
          onRemove: onRemoveSubPlace,
          onPickImage: (index) => onPickImage(index),
        ),
        SizedBox(height: size.height * 0.02),
        _buildLocationTile(context),
      ],
    );
  }

  Widget _buildLocationTile(BuildContext context) {
    return ListTile(
      tileColor: ColorManager.cardSurface.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: const Icon(Icons.location_on, color: ColorManager.egyptianEarth),
      title: Text(
        selectedLocation == null
            ? context.tr('pressToSelectLocation')
            : context.tr('locationSelectedSuccess'),
        style: const TextStyle(color: ColorManager.egyptianEarth, fontSize: 13),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: ColorManager.wasabi,
      ),
      onTap: () async {
        final LatLng? result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapSelectionScreen()),
        );
        if (result != null) {
          onLocationSelected(result);
        }
      },
    );
  }
}

