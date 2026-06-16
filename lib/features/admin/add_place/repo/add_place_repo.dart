// --- Replace add_place_repo.dart with this version ---

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/subplace_builder.dart';
import 'package:hanzbthalk/features/admin/add_place/repo/subplace_upload_helper.dart';

class AddPlaceRepo {
  final AdminService _adminService;
  final AuthService _authService;
  AddPlaceRepo(this._adminService, this._authService);

  Future<UserModel?> getOwnerById(String ownerId) async {
    try {
      return await _authService.getUserById(ownerId);
    } catch (e) {
      throw DatabaseException("Repo Error: Failed to get owner by ID -> $e");
    }
  }

  Future<List<UserModel>> searchOwners(String phone) {
    return _adminService.searchOwnersByPhone(phone);
  }

  Future<List<SubPlaceModel>> getSubPlacesByIds(List<String> ids) {
    return _adminService.getSubPlacesByIds(ids);
  }

  UploadTask startPlaceImageUpload({
    required File file,
    required String folderPath,
  }) {
    return _adminService.getUploadTask(file, folderPath);
  }

  // ─── Save / Create Mode ──────────────────────────────────────────────────

  /// Builds [SubPlaceModel]/[SlotsModel]s from raw [subPlacesData], uploads
  /// any local images (main + subplace), and persists everything for a
  /// brand-new place.
  Future<void> uploadAndSavePlace({
    required PlaceModel place,
    required List<Map<String, dynamic>> subPlacesData,
    required Function(double progress) onProgress,
  }) async {
    final String placeId = place.id.isEmpty
        ? _adminService.getNewPlaceId()
        : place.id;

    // New place -> no pre-existing subplaces to reconcile against.
    final subPlaceModels = buildAllSubPlaceModels(
      placeId: placeId,
      subPlacesData: subPlacesData,
      existingSubPlaces: const [],
    );
    final newSlots = buildNewSlotsModels(
      subPlaceModels: subPlaceModels,
      existingSubPlaces: const [],
    );

    final totalFiles = countLocalFilesToUpload(place.images, subPlaceModels);
    int uploadedCount = 0;
    void onFileUploaded() {
      uploadedCount++;
      onProgress((uploadedCount / totalFiles) * 100);
    }

    final finalMainImages = await uploadMainImages(
      adminService: _adminService,
      placeId: placeId,
      images: place.images,
      onFileUploaded: onFileUploaded,
    );

    final finalSubPlaces = await uploadSubPlaceImages(
      adminService: _adminService,
      placeId: placeId,
      subPlaces: subPlaceModels,
      onFileUploaded: onFileUploaded,
    );

    final finalPlace = place.copyWith(
      id: placeId,
      images: [
        ...finalMainImages,
        ...finalSubPlaces.map((sp) => sp.imageUrl).where((url) => url.isNotEmpty),
      ],
      subPlacesIds: finalSubPlaces.map((sp) => sp.id).toList(),
    );

    await _adminService
        .savePlaceData(
          place: finalPlace,
          subPlaces: finalSubPlaces,
          slotsList: newSlots,
        )
        .timeout(const Duration(seconds: 15));

    onProgress(100.0);
  }

  // ─── Update / Edit Mode ──────────────────────────────────────────────────

  /// Builds [SubPlaceModel]/[SlotsModel]s from raw [subPlacesData] (reusing
  /// `slotsIds` from [existingSubPlaces] where the subplace already
  /// existed), uploads any new local images (main + subplace), deletes
  /// images that were removed, and persists everything.
  Future<void> processPlaceUpdate({
    required PlaceModel updatedPlace,
    required List<Map<String, dynamic>> subPlacesData,
    required List<SubPlaceModel> existingSubPlaces,
    required Function(double progress) onProgress,
  }) async {
    final PlaceModel? oldPlace = await _adminService.getPlaceById(
      updatedPlace.id,
    );

    if (oldPlace == null) {
      throw const PlaceNotFoundException("old_version_not_found_to_edit");
    }

    final subPlaceModels = buildAllSubPlaceModels(
      placeId: updatedPlace.id,
      subPlacesData: subPlacesData,
      existingSubPlaces: existingSubPlaces,
    );
    final newSlots = buildNewSlotsModels(
      subPlaceModels: subPlaceModels,
      existingSubPlaces: existingSubPlaces,
    );
    final newSubPlaceIds = newSlots.map((s) => s.id).toSet();

    // ─── Collect removed image urls for background deletion ───
    final List<String> filesToDelete = [];

    final oldSubPlaceUrls = existingSubPlaces.map((sp) => sp.imageUrl).toSet();
    final oldMainUrls = oldPlace.images.where((img) => !oldSubPlaceUrls.contains(img)).toSet();

    for (var oldUrl in oldMainUrls) {
      if (!updatedPlace.images.contains(oldUrl)) {
        filesToDelete.add(oldUrl);
      }
    }

    final newSubPlaceImageUrls = subPlaceModels
        .map((sp) => sp.imageUrl)
        .toSet();
    for (var oldSub in existingSubPlaces) {
      if (oldSub.imageUrl.isNotEmpty &&
          !newSubPlaceImageUrls.contains(oldSub.imageUrl)) {
        filesToDelete.add(oldSub.imageUrl);
      }
    }

    if (filesToDelete.isNotEmpty) {
      _adminService.deleteMultipleFilesByUrls(filesToDelete).catchError((e) {
        debugPrint("Background deletion log: $e");
      });
    }

    // ─── Upload new local images ───
    final totalFiles = countLocalFilesToUpload(
      updatedPlace.images,
      subPlaceModels,
    );
    int uploadedCount = 0;
    void onFileUploaded() {
      uploadedCount++;
      onProgress((uploadedCount / totalFiles) * 100);
    }

    final finalImages = await uploadMainImages(
      adminService: _adminService,
      placeId: updatedPlace.id,
      images: updatedPlace.images,
      onFileUploaded: onFileUploaded,
    );

    final finalSubPlaces = await uploadSubPlaceImages(
      adminService: _adminService,
      placeId: updatedPlace.id,
      subPlaces: subPlaceModels,
      onFileUploaded: onFileUploaded,
    );

    final finalUpdatedPlace = updatedPlace.copyWith(
      images: [
        ...finalImages,
        ...finalSubPlaces.map((sp) => sp.imageUrl).where((url) => url.isNotEmpty),
      ],
      subPlacesIds: finalSubPlaces.map((sp) => sp.id).toList(),
    );

    await _adminService
        .updatePlaceWithSubPlaces(
          place: finalUpdatedPlace,
          allSubPlaces: finalSubPlaces,
          allSlots: newSlots,
          newSubPlaceIds: newSubPlaceIds,
        )
        .timeout(const Duration(seconds: 15));

    onProgress(100.0);
  }

  // ─── Delete Mode ──────────────────────────────────────────────────────────

  Future<void> completelyDeletePlace(PlaceModel place) async {
    final List<dynamic> allUrlsToDelete = [...place.images];

    final subPlaces = await _adminService.getSubPlacesByIds(place.subPlacesIds);
    for (var sub in subPlaces) {
      if (sub.imageUrl.isNotEmpty) allUrlsToDelete.add(sub.imageUrl);
    }

    await Future.wait([
      _adminService.deleteMultipleFilesByUrls(allUrlsToDelete),
      _adminService.completelyDeletePlace(place),
    ]);
  }
}
