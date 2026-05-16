import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:remaking_booking_app_trail2/core/db/admin_services.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

class AddPlaceRepo {
  final AdminService _adminService;
  final AuthService _authService;
  AddPlaceRepo(this._adminService, this._authService);

  Future<UserModel?> getOwnerById(String ownerId) async {
    try {
      return await _authService.getUserById(ownerId);
    } catch (e) {
      throw Exception("Repo Error: Failed to get owner by ID -> $e");
    }
  }

  Future<List<UserModel>> searchOwners(String phone) {
    return _adminService.searchOwnersByPhone(phone);
  }

  // ─── 🔥 تعديل 1: معالجة رفع الصور بالكامل بالتوازي (Concurrent Upload) ───
  Future<List<String>> _processImages(
    List<dynamic> images,
    String folderPath,
  ) async {
    // تجهيز لستة من المهام (Futures) بدون عمل await لكل وحدة على حدة
    final List<Future<String>> uploadTasks = images.map((item) async {
      if (item is String) {
        if (item.startsWith('http') || item.startsWith('https')) {
          return item; // صورة قديمة جاهزة
        } else if (item.isNotEmpty) {
          return await _adminService.uploadFile(
            File(item),
            folderPath,
          ); // مسار محلي
        }
      } else if (item is File) {
        return await _adminService.uploadFile(item, folderPath); // ملف حقيقي
      }
      return '';
    }).toList();

    // تشغيل الرفع بالكامل مع بعض في نفس الثانية
    final List<String> processedUrls = await Future.wait(uploadTasks);
    return processedUrls.where((url) => url.isNotEmpty).toList();
  }

  // ─── Save / Create Mode (رفع الصور الأساسية والفرعية معاً بالتوازي) ───
  Future<void> uploadAndSavePlace({required PlaceModel place}) async {
    String placeId = place.id.isEmpty
        ? _adminService.getNewPlaceId()
        : place.id;

    // 1. نجهز دالة رفع الصور الرئيسية في الخلفية
    final Future<List<String>> mainImagesTask = _processImages(
      place.images,
      "$placeId/main_images",
    );

    // 2. نجهز دالة رفع صور الملاعب الفرعية كلها بالتوازي
    final List<Future<SubPlace>> subPlaceTasks = place.subPlaces.map((
      sub,
    ) async {
      String subImageUrl = sub.imageUrl;
      if (subImageUrl.isNotEmpty && !subImageUrl.startsWith('http')) {
        subImageUrl = await _adminService.uploadFile(
          File(subImageUrl),
          "$placeId/${sub.id}",
        );
      }
      return sub.copyWith(imageUrl: subImageUrl);
    }).toList();

    // 3. 🔥 تشغيل الرفع الجماعي (الرئيسي والفرعي) في ضربة واحدة سريعة للشبكة
    final results = await Future.wait([
      mainImagesTask,
      Future.wait(subPlaceTasks),
    ]);

    final List<String> finalMainImages = results[0] as List<String>;
    final List<SubPlace> finalSubPlaces = results[1] as List<SubPlace>;

    // 4. الحفظ النهائي في Firestore
    final finalPlace = place.copyWith(
      id: placeId,
      images: finalMainImages,
      subPlaces: finalSubPlaces,
    );

    await _adminService.savePlace(finalPlace);
  }

  // ─── Update / Edit Mode (تنظيف الـ Storage في الخلفية بدون تعطيل الـ UI) ───
  Future<void> processPlaceUpdate({required PlaceModel updatedPlace}) async {
    final PlaceModel? oldPlace = await _adminService.getPlaceById(
      updatedPlace.id,
    );
    if (oldPlace == null) throw Exception("النسخة القديمة غير موجودة لتعديلها");

    List<String> filesToDelete = [];

    // 1. تجميع الصور الرئيسية الممسوحة
    for (var oldUrl in oldPlace.images) {
      if (!updatedPlace.images.contains(oldUrl)) {
        filesToDelete.add(oldUrl);
      }
    }

    // 2. تجميع صور الـ SubPlaces الممسوحة أو المعدلة
    List<Future<SubPlace>> subPlaceUploadTasks = updatedPlace.subPlaces.map((
      sub,
    ) async {
      String subUrl = sub.imageUrl;

      final oldSub = oldPlace.subPlaces.firstWhere(
        (element) => element.id == sub.id,
        orElse: () =>
            SubPlace(id: '', imageUrl: '', pricePerHour: 0, playersNumber: 0),
      );

      if (oldSub.id.isNotEmpty &&
          oldSub.imageUrl.isNotEmpty &&
          oldSub.imageUrl != subUrl) {
        filesToDelete.add(oldSub.imageUrl); // إضافة الصورة القديمة للحذف
      }

      if (subUrl.isNotEmpty && !subUrl.startsWith('http')) {
        subUrl = await _adminService.uploadFile(
          File(subUrl),
          "${updatedPlace.id}/${sub.id}",
        );
      }
      return sub.copyWith(imageUrl: subUrl);
    }).toList();

    // تجميع الـ SubPlaces التي حذفت بالكامل
    for (var oldSub in oldPlace.subPlaces) {
      final isStillExist = updatedPlace.subPlaces.any(
        (element) => element.id == oldSub.id,
      );
      if (!isStillExist && oldSub.imageUrl.isNotEmpty) {
        filesToDelete.add(oldSub.imageUrl);
      }
    }

    // 🚀 🔥 الـحـركـة الـسـحـريـة: إرسال أمر حذف الملفات القديمة بدون await!
    // الفايربيز هيحذفهم براحته في الخلفية دون قفل الـ Thread، والـ UI هيكمل فوراُ
    if (filesToDelete.isNotEmpty) {
      _adminService.deleteMultipleFilesByUrls(filesToDelete).catchError((e) {
        debugPrint("Background deletion log (safe to ignore for UI flow): $e");
      });
    }

    // 3. تشغيل عمليات الرفع الجديدة (الأساسية والفرعية) بالتوازي
    final Future<List<String>> mainImagesUploadTask = _processImages(
      updatedPlace.images,
      "${updatedPlace.id}/main_images",
    );

    final uploadResults = await Future.wait([
      mainImagesUploadTask,
      Future.wait(subPlaceUploadTasks),
    ]);

    final List<String> finalImages = uploadResults[0] as List<String>;
    final List<SubPlace> finalSubPlaces = uploadResults[1] as List<SubPlace>;

    // 4. التجميع النهائي والتحديث
    final finalUpdatedPlace = updatedPlace.copyWith(
      images: finalImages,
      subPlaces: finalSubPlaces,
    );

    await _adminService.updatePlace(finalUpdatedPlace);
  }

  // ─── Delete Mode (مسح شامل وكامل بضربة توازية واحدة) ───
  Future<void> completelyDeletePlace(PlaceModel place) async {
    List<dynamic> allUrlsToDelete = [];
    allUrlsToDelete.addAll(place.images);

    for (var sub in place.subPlaces) {
      if (sub.imageUrl.isNotEmpty) {
        allUrlsToDelete.add(sub.imageUrl);
      }
    }

    // حذف الصور وحذف المستند بالتوازي مع بعض!
    await Future.wait([
      _adminService.deleteMultipleFilesByUrls(allUrlsToDelete),
      _adminService.deletePlaceFromFirebase(place.id),
    ]);
  }
}
