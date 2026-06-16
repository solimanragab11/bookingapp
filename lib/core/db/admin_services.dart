import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:hanzbthalk/core/db/firestore_service.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/offer_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirestoreService _firestoreService = FirestoreService(); // تعريف الجوكر

  // ==========================================
  // --- 1. الإحصائيات (سطر واحد لكل دالة) ---
  // ==========================================

  Future<int> getPlacesCount() =>
      _firestoreService.countDocuments(_firestore.collection('places'));

  Future<int> getUsersCount() =>
      _firestoreService.countDocuments(_firestore.collection('users'));

  Future<int> getActiveOffersCount() => _firestoreService.countDocuments(
    _firestore.collection('offers').where('isActive', isEqualTo: true),
  );

  Stream<double> getTotalIncomeStream() {
    return _firestore.collection('bookings').snapshots().map((snapshot) {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalPrice'] ?? 0).toDouble();
      }
      return total;
    });
  }

  // ==========================================
  // --- 2. دوال البحث والمستخدمين ---
  // ==========================================

  Future<List<UserModel>> searchOwnersByPhone(String phone) {
    Query query = _firestore
        .collection('users')
        .where('userRole', isEqualTo: 'owner')
        .where('phoneNumber', isGreaterThanOrEqualTo: phone)
        .where('phoneNumber', isLessThanOrEqualTo: '$phone\uf8ff');
    return _firestoreService.getCollection(
      query: query,
      fromJson: UserModel.fromJson,
    );
  }

  Future<List<UserModel>> getAllUsers() {
    return _firestoreService.getCollection(
      query: _firestore.collection('users'),
      fromJson: UserModel.fromJson,
    );
  }

  Future<List<UserModel>> searchUsersByPhone(String phone) {
    Query query = _firestore
        .collection('users')
        .where('phoneNumber', isGreaterThanOrEqualTo: phone)
        .where('phoneNumber', isLessThanOrEqualTo: '$phone\uf8ff');
    return _firestoreService.getCollection(
      query: query,
      fromJson: UserModel.fromJson,
    );
  }

  Future<void> updateUserRoleInFirebase(String userId, String role) =>
      _firestoreService.updateDocument(
        collection: 'users',
        docId: userId,
        data: {'userRole': role},
      );

  // ==========================================
  // --- 3. جلب وتحديث الموديلز (بقت سطر واحد!) ---
  // ==========================================

  Future<PlaceModel?> getPlaceById(String id) => _firestoreService.getDocument(
    collection: 'places',
    docId: id,
    fromJson: PlaceModel.fromJson,
  );

  Future<SubPlaceModel?> getSubPlaceById(String id) =>
      _firestoreService.getDocument(
        collection: 'subplaces',
        docId: id,
        fromJson: SubPlaceModel.fromJson,
      );

  Future<SlotsModel?> getSlotsById(String id) => _firestoreService.getDocument(
    collection: 'slots',
    docId: id,
    fromJson: SlotsModel.fromJson,
  );

  Future<void> updatePlace(PlaceModel place) =>
      _firestoreService.updateDocument(
        collection: 'places',
        docId: place.id,
        data: place.toJson(),
      );

  Future<void> updateSubPlace(SubPlaceModel subPlace) =>
      _firestoreService.updateDocument(
        collection: 'subplaces',
        docId: subPlace.id,
        data: subPlace.toJson(),
      );

  Future<void> updateSlots(SlotsModel slots) =>
      _firestoreService.updateDocument(
        collection: 'slots',
        docId: slots.id,
        data: slots.toJson(),
      );

  // ==========================================
  // --- 4. العروض (Offers) ---
  // ==========================================

  String getNewOfferId() => _firestore.collection('offers').doc().id;

  Future<void> saveOffer(OfferModel offer) =>
      _firestore.collection('offers').doc(offer.id).set(offer.toJson());

  Future<void> updateOffer(OfferModel offer) =>
      _firestoreService.updateDocument(
        collection: 'offers',
        docId: offer.id,
        data: offer.toJson(),
      );

  Future<void> deleteOffer(String id) =>
      _firestoreService.deleteDocument(collection: 'offers', docId: id);

  Future<List<OfferModel>> getAllOffers() {
    Query query = _firestore
        .collection('offers')
        .orderBy('createdAt', descending: true);
    return _firestoreService.getCollection(
      query: query,
      fromJson: OfferModel.fromJson,
    );
  }

  // ==========================================
  // --- 5. عمليات الـ Batch الشاملة (Places) ---
  // ==========================================
  String getNewPlaceId() => _firestore.collection('places').doc().id;

  Future<void> savePlaceData({
    required PlaceModel place,
    required List<SubPlaceModel> subPlaces,
    required List<SlotsModel> slotsList,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      batch.set(_firestore.collection('places').doc(place.id), place.toJson());
      for (var sp in subPlaces) {
        batch.set(_firestore.collection('subplaces').doc(sp.id), sp.toJson());
      }
      for (var sl in slotsList) {
        batch.set(_firestore.collection('slots').doc(sl.id), sl.toJson());
      }
      await batch.commit();
      debugPrint('تم حفظ المكان بنجاح!');
    } catch (e) {
      throw DatabaseException('failed_to_save_place');
    }
  }

  Future<void> updateFullPlaceData({
    required PlaceModel place,
    required List<SubPlaceModel> subPlaces,
    required List<SlotsModel> slotsList,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      batch.update(
        _firestore.collection('places').doc(place.id),
        place.toJson(),
      );
      for (var sp in subPlaces) {
        batch.update(
          _firestore.collection('subplaces').doc(sp.id),
          sp.toJson(),
        );
      }
      for (var sl in slotsList) {
        batch.update(_firestore.collection('slots').doc(sl.id), sl.toJson());
      }
      await batch.commit();
      debugPrint('تم تحديث المكان بنجاح!');
    } catch (e) {
      throw DatabaseException('failed_to_update_place');
    }
  }

  Future<void> completelyDeletePlace(PlaceModel place) async {
    try {
      if (place.images.isNotEmpty) {
        await deleteMultipleFilesByUrls(place.images);
      }

      WriteBatch batch = _firestore.batch();
      batch.delete(_firestore.collection('places').doc(place.id));

      for (String subPlaceId in place.subPlacesIds) {
        final subPlace = await getSubPlaceById(subPlaceId);
        if (subPlace != null) {
          for (String slotId in subPlace.slotsIds) {
            batch.delete(_firestore.collection('slots').doc(slotId));
          }
        }
        batch.delete(_firestore.collection('subplaces').doc(subPlaceId));
      }

      await batch.commit();
      debugPrint('تم مسح المكان ومحتوياته بنجاح!');
    } catch (e) {
      throw DatabaseException('failed_to_delete_place');
    }
  }

  // ==========================================
  // --- 6. الـ Storage ---
  // ==========================================
  Future<void> deleteFileByUrl(String fileUrl) async {
    if (fileUrl.isEmpty) return;
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (e) {
      debugPrint("خطأ في مسح الصورة: $e");
    }
  }

  Future<void> deleteMultipleFilesByUrls(List<dynamic> imageUrls) async {
    if (imageUrls.isEmpty) return;
    final validUrls = imageUrls
        .where((url) => url != null && url.toString().isNotEmpty)
        .map((url) => url.toString());
    await Future.wait(validUrls.map((url) => deleteFileByUrl(url)));
  }

  Future<String> uploadFile(File file, String path) async {
    String fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    Reference ref = _storage.ref().child('$path/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  UploadTask getUploadTask(File file, String path) {
    String fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    return _storage.ref().child('$path/$fileName').putFile(file);
  }

  // --- Add inside AdminService ---

  /// Fetches multiple [SubPlaceModel]s by their ids in parallel.
  ///
  /// Ids that don't resolve to an existing document are silently skipped.
  Future<List<SubPlaceModel>> getSubPlacesByIds(List<String> ids) async {
    final results = await Future.wait(ids.map(getSubPlaceById));
    return results.whereType<SubPlaceModel>().toList();
  }

  /// Updates [place] and persists [allSubPlaces] + [allSlots] in a single
  /// batch, correctly handling a mix of brand-new and pre-existing
  /// subplace/slot documents.
  ///
  /// - Docs whose id is in [newSubPlaceIds] are written with `set` (they
  ///   don't exist yet, so `update` would throw).
  /// - All other docs are written with `update`.
  Future<void> updatePlaceWithSubPlaces({
    required PlaceModel place,
    required List<SubPlaceModel> allSubPlaces,
    required List<SlotsModel> allSlots,
    required Set<String> newSubPlaceIds,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();

      batch.update(
        _firestore.collection('places').doc(place.id),
        place.toJson(),
      );

      for (var sp in allSubPlaces) {
        final ref = _firestore.collection('subplaces').doc(sp.id);
        if (newSubPlaceIds.contains(sp.id)) {
          batch.set(ref, sp.toJson());
        } else {
          batch.update(ref, sp.toJson());
        }
      }

      for (var sl in allSlots) {
        final ref = _firestore.collection('slots').doc(sl.id);
        if (newSubPlaceIds.contains(sl.id)) {
          batch.set(ref, sl.toJson());
        } else {
          batch.update(ref, sl.toJson());
        }
      }

      await batch.commit();
      debugPrint('تم تحديث المكان والأماكن الفرعية بنجاح!');
    } catch (e) {
      throw DatabaseException(
        "failed_to_update_place_subplaces",
      );
    }
  }
}
