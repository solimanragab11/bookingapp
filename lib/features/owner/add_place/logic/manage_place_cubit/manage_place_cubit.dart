import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';

import 'manage_place_state.dart';

class ManagePlaceCubit extends Cubit<ManagePlaceState> {
  ManagePlaceCubit() : super(ManagePlaceState.initial());

  final ImagePicker _picker = ImagePicker();

  void updatePlaceData({
    String? name,
    String? desc,
    String? category,
    List<SubPlace>? subPlaces,
    double? minCharge,
    List<String>? images,
    LatLng? location,
  }) {
    final updatedPlace = state.place.copyWith(
      name: name ?? state.place.name,
      description: desc ?? state.place.description,
      type: category ?? state.place.type,
      subPlaces: subPlaces ?? state.place.subPlaces,
      minimumCharge: minCharge ?? state.place.minimumCharge,
      images: images ?? state.place.images,
      latitude: location?.latitude ?? state.place.latitude,
      longitude: location?.longitude ?? state.place.longitude,
    );
    emit(state.copyWith(place: updatedPlace));
  }

  /// يجمع بيانات الشاشة (قبل الحفظ) ثم ينادي savePlace
  Future<void> submitPlaceData({
    required String name,
    required String desc,
    required String? category,
    required List<Map<String, dynamic>> subPlacesRaw,
    required double minCharge,
    required List<File> mainImages,
    required LatLng? location,
  }) async {
    final List<SubPlace> subPlaceModels = _mapSubPlaces(subPlacesRaw);

    updatePlaceData(
      name: name,
      desc: desc,
      category: category,
      subPlaces: subPlaceModels,
      minCharge: minCharge,
      images: mainImages.map((f) => f.path).toList(),
      location: location,
    );

    await savePlace();
  }

  /// يحوّل الـ Map اللي جاي من الواجهات لقائمة SubPlace موديل
  List<SubPlace> _mapSubPlaces(List<Map<String, dynamic>> rawSubPlaces) {
    return rawSubPlaces.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      return SubPlace(
        id: (index + 1).toString(),
        imageUrl: (data['image'] as File?)?.path ?? '',
        pricePerHour:
            double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
        playersNumber:
            int.tryParse(data['size']?.toString() ?? '') ?? 0,
      );
    }).toList();
  }

  /// ميثود مساعدة لاختيار صورة ملعب فرعي
  Future<File?> pickSubPlaceImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img == null) return null;
    return File(img.path);
  }

  /// ميثود مساعدة لاختيار صور المكان الأساسية (متعددة)
  Future<List<File>> pickMainImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    return images.map((e) => File(e.path)).toList();
  }

  Future<void> savePlace() async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null,
      ),
    );
    try {
      final String placeId = state.place.id.isEmpty
          ? FirebaseFirestore.instance.collection('places').doc().id
          : state.place.id;
      final String ownerId = state.place.ownerId;

      // 1. رفع صور المكان الأساسية
      List<String> uploadedImages = [];
      for (var path in state.place.images) {
        if (!path.startsWith('http')) {
          uploadedImages.add(
            await _uploadFile(File(path), "$ownerId/$placeId/main_images"),
          );
        } else {
          uploadedImages.add(path);
        }
      }

      // 2. رفع صور الملاعب الفرعية
      List<SubPlace> updatedSub = [];
      for (var sub in state.place.subPlaces) {
        String url = sub.imageUrl;
        if (url.isNotEmpty && !url.startsWith('http')) {
          url = await _uploadFile(
            File(url),
            "$ownerId/$placeId/${sub.id}/images",
          );
        }
        updatedSub.add(sub.copyWith(imageUrl: url));
      }

      // 3. الحفظ النهائي
      final finalPlace = state.place.copyWith(
        id: placeId,
        images: uploadedImages,
        subPlaces: updatedSub,
      );
      await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .set(finalPlace.toJson());

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: () => e.toString()));
    }
  }

  Future<String> _uploadFile(File file, String folder) async {
    String name =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    Reference ref = FirebaseStorage.instance.ref().child('$folder/$name');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  void reset() => emit(ManagePlaceState.initial());
}
