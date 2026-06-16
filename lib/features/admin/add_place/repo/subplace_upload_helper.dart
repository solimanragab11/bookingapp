import 'dart:io';

import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';

/// Returns true if [value] represents a local file that still needs
/// uploading (a [File] instance, or a non-empty string that isn't already
/// an `http`/`https` url).
bool isLocalFileReference(dynamic value) {
  if (value is File) return true;
  if (value is String && value.isNotEmpty && !value.startsWith('http')) {
    return true;
  }
  return false;
}

/// Counts how many entries across [mainImages] and [subPlaces] still need
/// to be uploaded (i.e. are local files, not existing urls).
///
/// Returns at least 1 to avoid division-by-zero when computing progress.
int countLocalFilesToUpload(
  List<dynamic> mainImages,
  List<SubPlaceModel> subPlaces,
) {
  int count = 0;

  for (var item in mainImages) {
    if (isLocalFileReference(item)) count++;
  }

  for (var sub in subPlaces) {
    if (isLocalFileReference(sub.imageUrl)) count++;
  }

  return count == 0 ? 1 : count;
}

/// Uploads the main place images, returning the final list of urls.
///
/// Already-uploaded `http(s)` urls pass through unchanged. [onFileUploaded]
/// is called once per file actually uploaded (for progress reporting).
Future<List<String>> uploadMainImages({
  required AdminService adminService,
  required String placeId,
  required List<dynamic> images,
  required void Function() onFileUploaded,
}) async {
  final List<String> finalImages = [];

  for (var item in images) {
    if (item is String && item.startsWith('http')) {
      finalImages.add(item);
      continue;
    }

    final File file = item is File ? item : File(item.toString());
    final url = await adminService.uploadFile(file, "$placeId/main_images");
    finalImages.add(url);
    onFileUploaded();
  }

  return finalImages;
}

/// Uploads any local subplace images (where `imageUrl` is a local file
/// path), returning updated [SubPlaceModel]s with final urls.
///
/// Subplaces whose `imageUrl` is already an `http(s)` url, or empty, pass
/// through unchanged. [onFileUploaded] is called once per file actually
/// uploaded (for progress reporting).
Future<List<SubPlaceModel>> uploadSubPlaceImages({
  required AdminService adminService,
  required String placeId,
  required List<SubPlaceModel> subPlaces,
  required void Function() onFileUploaded,
}) async {
  final List<SubPlaceModel> result = [];

  for (var sub in subPlaces) {
    if (!isLocalFileReference(sub.imageUrl)) {
      result.add(sub);
      continue;
    }

    final url = await adminService.uploadFile(
      File(sub.imageUrl),
      "$placeId/${sub.id}",
    );
    onFileUploaded();
    result.add(sub.copyWith(imageUrl: url));
  }

  return result;
}
