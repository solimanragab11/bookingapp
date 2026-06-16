import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- دالة عامة لجلب Document واحد ---
  Future<T?> getDocument<T>({
    required String collection,
    required String docId,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      if (doc.exists && doc.data() != null) {
        return fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching $docId from $collection: $e");
      return null;
    }
  }

  // --- دالة عامة لجلب Collection كامل أو Query ---
  Future<List<T>> getCollection<T>({
    required Query query,
    required T Function(Map<String, dynamic> data) fromJson,
  }) async {
    try {
      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching collection: $e");
      return [];
    }
  }

  // --- دالة عامة للتحديث ---
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception("Failed to update $collection: $e");
    }
  }

  // --- دالة عامة للحذف ---
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      throw Exception("Failed to delete $collection: $e");
    }
  }

  // --- دالة عامة للعد (الإحصائيات) ---
  Future<int> countDocuments(Query query) async {
    try {
      final aggregateQuery = await query.count().get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      debugPrint("Error counting documents: $e");
      return 0;
    }
  }
}
