import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<int> getPlacesCount() async {
    try {
      final aggregateQuery = await _firestore
          .collection('places')
          .count()
          .get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      debugPrint("Error fetching places count: $e");
      return 0;
    }
  }

  Future<int> getUsersCount() async {
    try {
      final aggregateQuery = await _firestore.collection('users').count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      debugPrint("Error fetching users count: $e");
      return 0;
    }
  }

  Future<int> getActiveOffersCount() async {
    try {
      final aggregateQuery = await _firestore
          .collection('offers')
          .where('isActive', isEqualTo: true)
          .count()
          .get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      debugPrint("Error fetching active offers count: $e");
      return 0;
    }
  }

  Stream<double> getTotalIncomeStream() {
    return _firestore.collection('bookings').snapshots().map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalPrice'] ?? 0).toDouble();
      }
      return total;
    });
  }

  Future<List<UserModel>> searchOwnersByPhone(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('userRole', isEqualTo: 'owner')
          .where('phoneNumber', isGreaterThanOrEqualTo: phone)
          .where('phoneNumber', isLessThanOrEqualTo: '$phone\uf8ff')
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<List<UserModel>> searchUsersByPhone(String phone) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isGreaterThanOrEqualTo: phone)
          .where('phoneNumber', isLessThanOrEqualTo: '$phone\uf8ff')
          .get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  // --- دالات الـ Storage المجرّدة ---

  Future<void> deleteFileByUrl(String fileUrl) async {
    if (fileUrl.isEmpty) return;
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint("خطأ أثناء حذف الصورة من الستوريدج: $e");
    }
  }

  /// دالة حذف جماعي محسنة وتوازية بالكامل
  Future<void> deleteMultipleFilesByUrls(List<dynamic> imageUrls) async {
    if (imageUrls.isEmpty) return;

    // فلترة وتنظيف الروابط لضمان عدم تمرير قيم فارغة
    final List<String> validUrls = imageUrls
        .where((url) => url != null && url.toString().isNotEmpty)
        .map((url) => url.toString())
        .toList();

    final List<Future<void>> deleteTasks = validUrls
        .map((url) => deleteFileByUrl(url))
        .toList();

    await Future.wait(deleteTasks);
  }

  Future<String> uploadFile(File file, String path) async {
    String fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    Reference ref = _storage.ref().child('$path/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // --- دالات الـ Firestore الخاصة بالـ Places ---

  String getNewPlaceId() => _firestore.collection('places').doc().id;

  Future<void> savePlace(PlaceModel place) async {
    await _firestore.collection('places').doc(place.id).set(place.toJson());
  }

  Future<void> updatePlace(PlaceModel place) async {
    try {
      await _firestore
          .collection('places')
          .doc(place.id)
          .update(place.toJson());
    } catch (e) {
      throw Exception("Failed to update place: $e");
    }
  }

  Future<void> completelyDeletePlace(PlaceModel place) async {
    try {
      if (place.images.isNotEmpty) {
        await deleteMultipleFilesByUrls(place.images);
      }
      await deletePlaceFromFirebase(place.id);
    } catch (e) {
      throw Exception("فشل في حذف المكان ومحتوياته بالكامل: $e");
    }
  }

  Future<void> deletePlaceFromFirebase(String id) async {
    await _firestore.collection('places').doc(id).delete();
  }

  Future<void> updateUserRoleInFirebase(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({'userRole': role});
  }

  Future<PlaceModel?> getPlaceById(String placeId) async {
    try {
      final doc = await _firestore.collection('places').doc(placeId).get();
      if (doc.exists && doc.data() != null) {
        return PlaceModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("خطأ أثناء جلب بيانات المكان $placeId: $e");
      return null;
    }
  }
}
