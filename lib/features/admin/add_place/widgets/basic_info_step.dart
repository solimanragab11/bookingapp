import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/add_place_text_field.dart';

class BasicInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  const BasicInfoStep({
    super.key,
    required this.nameController,
    required this.descController,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        AddPlaceTextField(
          label: context.tr('fullName'),
          controller: nameController,
          icon: Icons.store,
        ),
        SizedBox(height: size.height * 0.02),
        AddPlaceTextField(
          label: context.tr('description'),
          controller: descController,
          icon: Icons.info_outline,
          maxLines: 3,
        ),
        SizedBox(height: size.height * 0.02),
        _buildCategoryDropdown(context),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    final Map<String, String> categories = {
      'padel': context.tr('Padel'),
      'football': context.tr('Football'),
      'playstation': context.tr('PlayStation'),
      'cafe': context.tr('Cafe'),
    };

    return DropdownButtonFormField<String>(
      dropdownColor: ColorManager.cardSurface,
      style: const TextStyle(color: ColorManager.creasedKhaki),
      decoration: InputDecoration(
        labelText: context.tr('category'),
        prefixIcon: const Icon(
          Icons.category,
          color: ColorManager.egyptianEarth,
        ),
        filled: true,
        fillColor: ColorManager.cardSurface.withOpacity(0.8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ColorManager.emeraldGreen),
        ),
      ),
      value: selectedCategory,
      items: categories.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onCategoryChanged,
      validator: (value) => value == null ? context.tr('fieldRequired') : null,
    );
  }
}

