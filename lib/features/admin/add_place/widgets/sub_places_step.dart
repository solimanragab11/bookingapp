import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/add_place_text_field.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/sub_places_list_section.dart.dart';

class SubPlacesStep extends StatelessWidget {
  final String? selectedCategory;
  final TextEditingController minChargeController;
  final List<Map<String, dynamic>> subPlaces;
  final String? selectedAddress;

  /// Opens map via named route; parent handles [Navigator.pushNamed] and state.
  final Future<void> Function() onOpenMapSelection;
  final VoidCallback onAddSubPlace;
  final ValueChanged<int> onRemoveSubPlace;
  final Future<void> Function(int) onPickImage;

  const SubPlacesStep({
    super.key,
    required this.selectedCategory,
    required this.minChargeController,
    required this.subPlaces,
    required this.selectedAddress,
    required this.onOpenMapSelection,
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
    final hasLocation = selectedAddress != null && selectedAddress!.isNotEmpty;
    return ListTile(
      tileColor: ColorManager.cardSurface.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: const Icon(Icons.location_on, color: ColorManager.egyptianEarth),
      title: Text(
        hasLocation
            ? context.tr('locationSelectedSuccess')
            : context.tr('pressToSelectLocation'),
        style: const TextStyle(color: ColorManager.egyptianEarth, fontSize: 13),
      ),
      subtitle: hasLocation
          ? Text(
              selectedAddress!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ColorManager.creasedKhaki,
                fontSize: 11,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: ColorManager.wasabi,
      ),
      onTap: () async {
        await onOpenMapSelection();
      },
    );
  }
}
