import 'dart:io';
import 'package:remaking_booking_app_trail2/core/db/admin_services.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

class AddPlaceRepo {
  final AdminService _adminService;
  AddPlaceRepo(this._adminService);

  Future<List<UserModel>> searchOwners(String phone) {
    return _adminService.searchOwnersByPhone(phone);
  }

  Future<void> uploadAndSavePlace({required PlaceModel place}) async {
    String placeId = place.id.isEmpty
        ? _adminService.getNewPlaceId()
        : place.id;
    String ownerId = place.ownerId;

    // 1. معالجة الصور الأساسية (تطابق الـ Cubit القديم 100%)
    List<String> finalMainImages = [];
    for (var path in place.images) {
      if (path.isNotEmpty && !path.startsWith('http')) {
        // لو مسار محلي ارفعه
        String url = await _adminService.uploadFile(
          File(path),
          "$ownerId/$placeId/main_images",
        );
        finalMainImages.add(url);
      } else {
        // لو هو رابط أصلاً سيبه زي ما هو
        finalMainImages.add(path);
      }
    }

    // 2. معالجة صور الملاعب الفرعية (تطابق الـ Cubit القديم 100%)
    List<SubPlace> finalSubPlaces = [];
    for (var sub in place.subPlaces) {
      String subImageUrl = sub.imageUrl;
      if (subImageUrl.isNotEmpty && !subImageUrl.startsWith('http')) {
        subImageUrl = await _adminService.uploadFile(
          File(subImageUrl),
          "$ownerId/$placeId/${sub.id}/sub_images",
        );
      }
      finalSubPlaces.add(sub.copyWith(imageUrl: subImageUrl));
    }

    // 3. الحفظ النهائي
    final finalPlace = place.copyWith(
      id: placeId,
      images: finalMainImages,
      subPlaces: finalSubPlaces,
    );

    await _adminService.savePlace(finalPlace);
  }

  Future<void> processPlaceUpdate(PlaceModel place) async {
    // 1. معالجة الصور الرئيسية
    List<String> finalImages = [];
    for (var path in place.images) {
      if (path.startsWith('http')) {
        finalImages.add(path); // صورة قديمة
      } else {
        String url = await _adminService.uploadFile(
          File(path),
          "places_images",
        );
        finalImages.add(url); // صورة جديدة اترفت
      }
    }

    // 2. معالجة صور الـ SubPlaces
    List<SubPlace> finalSubPlaces = [];
    for (var sub in place.subPlaces) {
      String subUrl = sub.imageUrl;
      if (subUrl.isNotEmpty && !subUrl.startsWith('http')) {
        subUrl = await _adminService.uploadFile(
          File(subUrl),
          "subplaces_images",
        );
      }
      finalSubPlaces.add(sub.copyWith(imageUrl: subUrl));
    }

    // 3. تجميع المكان النهائي وتحديثه
    final updatedPlace = place.copyWith(
      images: finalImages,
      subPlaces: finalSubPlaces,
    );

    await _adminService.updatePlace(updatedPlace);
  }
}
