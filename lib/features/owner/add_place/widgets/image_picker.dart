import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // ميثود تفتح الجاليري وترجع الملف
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // بنقلل الجودة شوية عشان الرفع يبقى سريع
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // ميثود تفتح الكاميرا
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
