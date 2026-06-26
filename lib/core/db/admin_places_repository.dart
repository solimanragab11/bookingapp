import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hanzbthalk/core/db/firebase_storage_service.dart';
import 'package:hanzbthalk/core/db/firestore_service.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';

class AdminPlacesRepository {
  final FirebaseFirestore _firestore;
  final FirestoreService _firestoreService;
  final FirebaseStorageService _storageService;

  // Constructor Injection
  AdminPlacesRepository({
    FirebaseFirestore? firestore,
    FirestoreService? firestoreService,
    FirebaseStorageService? storageService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firestoreService = firestoreService ?? FirestoreService(),
       _storageService = storageService ?? FirebaseStorageService();

  String getNewPlaceId() => _firestore.collection('places').doc().id;

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

  Future<List<SubPlaceModel>> getSubPlacesByIds(List<String> ids) async {
    final results = await Future.wait(ids.map(getSubPlaceById));
    return results.whereType<SubPlaceModel>().toList();
  }

  Future<SlotsModel?> getSlotsById(String id) => _firestoreService.getDocument(
    collection: 'slots',
    docId: id,
    fromJson: SlotsModel.fromJson,
  );

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

  Future<void> completelyDeletePlace(PlaceModel place) async {
    try {
      if (place.images.isNotEmpty) {
        await _storageService.deleteMultipleFilesByUrls(place.images);
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

  // ... (باقي دوال الـ update الخاصة بالـ Places بنفس النمط)
}
