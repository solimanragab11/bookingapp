import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. Stream لعدد الأماكن - يتحدث تلقائياً عند إضافة أو حذف مكان
  Stream<int> getPlacesCountStream() {
    return _firestore
        .collection('places')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 2. Stream لعدد المستخدمين - يتحدث عند تسجيل يوزر جديد
  Stream<int> getUsersCountStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 3. Stream للعروض النشطة فقط
  Stream<int> getActiveOffersCountStream() {
    return _firestore
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // 4. Stream للدخل الإجمالي - سحري! أي حجز جديد يرفع الرقم فوراً
  Stream<double> getTotalIncomeStream() {
    return _firestore.collection('bookings').snapshots().map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalPrice'] ?? 0).toDouble();
      }
      return total;
    });
  }

  // --- باقي الدوال (Future) كما هي لأنها Actions وليست Data Monitoring ---

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
      print(e);
      return [];
    }
  }

  Future<String> uploadFile(File file, String path) async {
    String fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    Reference ref = _storage.ref().child('$path/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> savePlace(PlaceModel place) async {
    await _firestore.collection('places').doc(place.id).set(place.toJson());
  }

  String getNewPlaceId() => _firestore.collection('places').doc().id;

  Future<void> deletePlaceFromFirebase(String id) async {
    await _firestore.collection('places').doc(id).delete();
  }

  Future<void> updateUserRoleInFirebase(String userId, String role) async {
    await _firestore.collection('users').doc(userId).update({'role': role});
  }
}
