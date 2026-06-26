import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/localization/admin_localization_keys.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadFile(File file, String path) async {
    try {
      final String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
      final Reference ref = _storage.ref().child('$path/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw DatabaseException(AdminLocalizationKeys.failedToSavePlace);
    }
  }

  UploadTask getUploadTask(File file, String path) {
    final String fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    return _storage.ref().child('$path/$fileName').putFile(file);
  }

  Future<void> deleteFileByUrl(String fileUrl) async {
    if (fileUrl.isEmpty) return;
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (e) {
      debugPrint("${AdminLocalizationKeys.errorDeletingImage}: $e");
    }
  }

  Future<void> deleteMultipleFilesByUrls(List<dynamic> imageUrls) async {
    if (imageUrls.isEmpty) return;
    final validUrls = imageUrls
        .where((url) => url != null && url.toString().isNotEmpty)
        .map((url) => url.toString());
    await Future.wait(validUrls.map((url) => deleteFileByUrl(url)));
  }
}
