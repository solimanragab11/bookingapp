import 'dart:io';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class SubPlacesListSection extends StatelessWidget {
  final List<Map<String, dynamic>> subPlaces;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final Function(int) onPickImage;

  const SubPlacesListSection({
    super.key,
    required this.subPlaces,
    required this.onAdd,
    required this.onRemove,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Available Fields",
              style: TextStyle(
                color: ColorManager.creasedKhaki,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: ColorManager.egyptianEarth,
              ),
              onPressed: onAdd,
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subPlaces.length,
          itemBuilder: (context, index) {
            // الـ ID بيتحسب هنا: index + 1
            return _buildSubPlaceCard(index, (index + 1).toString());
          },
        ),
      ],
    );
  }

  Widget _buildSubPlaceCard(int index, String id) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ColorManager.emeraldGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Field #$id",
            style: const TextStyle(color: ColorManager.wasabi, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildImagePicker(index),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallField(
                  "Size (e.g. 5x5)",
                  (val) => subPlaces[index]['playersNumber'] = val,
                  isNumber: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSmallField(
                  "Price",
                  (val) => subPlaces[index]['price'] = val,
                  isNumber: true,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                onPressed: () => onRemove(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(int index) {
    return GestureDetector(
      onTap: () => onPickImage(index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: ColorManager.noirDeVigne,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorManager.wasabi),
        ),
        child: subPlaces[index]['image'] == null
            ? const Icon(
                Icons.add_a_photo,
                size: 20,
                color: ColorManager.wasabi,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  subPlaces[index]['image'] as File,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildSmallField(
    String hint,
    Function(String) onChanged, {
    bool isNumber = false,
  }) {
    return TextFormField(
      style: const TextStyle(color: ColorManager.creasedKhaki, fontSize: 14),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ColorManager.wasabi, fontSize: 12),
        filled: true,
        fillColor: ColorManager.noirDeVigne,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
