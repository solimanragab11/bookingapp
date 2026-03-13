import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:path/path.dart'
    as p; // بنستخدمه عشان نجيب الـ extension (jpg/png)

class FirestoreOwnerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة مكان جديد
  Future<void> addPlace(Place place) async {
    await _firestore.collection('places').doc(place.id).set(place.toJson());
  }

  // جلب الأماكن الخاصة بـ Owner معين
  Future<List<Place>> getPlacesByOwner(String ownerId) async {
    // ملحوظة لعمي السولي: هنا بنستخدم الـ ownerId اللي جوه الـ Place model
    QuerySnapshot querySnapshot = await _firestore
        .collection('places')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return querySnapshot.docs
        .map((doc) => Place.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // حذف مكان بكل صوره بدون المساس بالحجوزات
  Future<void> deletePlaceWithImages({
    required String placeId,
    required String ownerId,
  }) async {
    // بنفترض إن الصور محفوظة في مسار منسق حسب الـ ownerId والـ placeId
    final placeDocRef = _firestore.collection('places').doc(placeId);

    // 1) هنجلب بيانات المكان عشان نعرف روابط الصور
    final placeSnapshot = await placeDocRef.get();
    if (!placeSnapshot.exists) {
      return;
    }
    final data = placeSnapshot.data() as Map<String, dynamic>;

    // 2) نجمع كل روابط الصور (المكان + الملاعب الفرعية) مع دعم Map/List
    final List<String> allImageUrls = [];

    // images ممكن تبقى List أو Map أو String
    final dynamic imagesField = data['images'];
    if (imagesField is List) {
      for (final item in imagesField) {
        if (item is String && item.isNotEmpty) {
          allImageUrls.add(item);
        }
      }
    } else if (imagesField is Map) {
      for (final value in imagesField.values) {
        if (value is String && value.isNotEmpty) {
          allImageUrls.add(value);
        }
      }
    } else if (imagesField is String && imagesField.isNotEmpty) {
      allImageUrls.add(imagesField);
    }

    // subPlaces ممكن تبقى List أو Map
    final dynamic subPlacesField = data['subPlaces'];
    if (subPlacesField is List) {
      for (final sp in subPlacesField) {
        if (sp is Map<String, dynamic>) {
          final img = sp['imageUrl'];
          if (img is String && img.isNotEmpty) {
            allImageUrls.add(img);
          }
        }
      }
    } else if (subPlacesField is Map) {
      for (final sp in subPlacesField.values) {
        if (sp is Map<String, dynamic>) {
          final img = sp['imageUrl'];
          if (img is String && img.isNotEmpty) {
            allImageUrls.add(img);
          }
        }
      }
    }

    // 3) نحذف أي Sub-Collections معروفه (مثلاً subPlaces كـ Sub-Collection)
    final batch = _firestore.batch();

    // نحاول نمسح Sub-Collection باسم "subPlaces" لو موجودة
    final subPlacesCollection = placeDocRef.collection('subPlaces');
    final subPlacesSnapshot = await subPlacesCollection.get();
    for (final doc in subPlacesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 4) نحذف الدوكيومنت نفسه ضمن الـ Batch
    batch.delete(placeDocRef);
    await batch.commit();

    // 5) بعد نجاح حذف الداتا، نحذف الصور من Firebase Storage (مالهاش علاقة بالحجوزات)
    for (final url in allImageUrls) {
      try {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (_) {
        // لو صورة مش موجودة أو فيه خطأ في الحذف، بنطنش عشان منوقعش العملية كلها
      }
    }
  }

  Future<void> updateSubPlaceDetails(
    String placeId,
    String subPlaceId,
    Map<String, dynamic> details,
  ) async {
    final DocumentReference placeRef = _firestore
        .collection('places')
        .doc(placeId);
    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot placeSnapshot = await transaction.get(placeRef);
      if (!placeSnapshot.exists) throw Exception('Place not found!');

      final placeData = placeSnapshot.data() as Map<String, dynamic>;
      List<dynamic> subPlacesData = placeData['subPlaces'] ?? [];
      final index = subPlacesData.indexWhere((sp) => sp['id'] == subPlaceId);

      if (index != -1) {
        subPlacesData[index].addAll(details);
        transaction.update(placeRef, {'subPlaces': subPlacesData});
      }
    });
  }

  final _storage = FirebaseStorage.instance;

  static downscaleImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final String targetPath = p.join(
        tempDir.path,
        "compressed_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      // التعديل هنا: بنستخدم XFile ونتأكد من المسار
      var result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path, // مسار الملف الأصلي
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg, // حدد الفورمات صراحة
      );

      return result;
    } catch (e) {
      // هنا هيطبعلك السبب الحقيقي لو لسه فيه مشكلة
      print("Error during DownScaling: $e");
      return null;
    }
  }

  static Future<String?> uploadADownscaledImage(File imageFile) async {
    try {
      var downScaledImage = await downscaleImage(imageFile);

      File fileToUpload = File(downScaledImage.path);
      String fileName = p.basename(fileToUpload.path);

      Reference storageRef = FirebaseStorage.instance.ref().child(
        'uploads/bookings/$fileName',
      );

      // الرفع
      UploadTask uploadTask = storageRef.putFile(fileToUpload);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // هنا هيطبعلك السبب الحقيقي لو لسه فيه مشكلة
      print("Error during upload: $e");
      return null;
    }
  }

  // 1. جلب كل أماكن صاحب المكان ده بس
  Stream<List<Place>> getOwnerPlaces(String ownerId) {
    return _firestore
        .collection('places')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Place.fromJson(doc.data())).toList(),
        );
  }

  // 2. حساب التحليلات لكل مكان (Live Analysis)
  Future<Map<String, dynamic>> getPlaceAnalysis(String placeId) async {
    // جلب كل الحجوزات الناجحة للمكان ده
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('placeId', isEqualTo: placeId)
        .where('status', isEqualTo: 'confirmed') // الحجوزات المؤكدة بس
        .get();

    double totalRevenue = 0;
    int totalBookings = querySnapshot.docs.length;

    for (var doc in querySnapshot.docs) {
      totalRevenue += (doc.data()['price'] ?? 0).toDouble();
    }

    return {'revenue': totalRevenue, 'bookingsCount': totalBookings};
  }

  Future<void> bookTimeSlot({
    required String placeId,
    required int subPlaceIndex, // رقم الملعب (0, 1, 2...)
    required String day, // "friday"
    required String timeSlot, // "0:00"
  }) async {
    final docRef = _firestore.collection('places').doc(placeId);

    // بنستخدم الـ dot notation عشان نوصل للحقل اللي جوه الـ Map
    await docRef.update({
      // 1. نشيل الساعة من المتاح
      'subPlaces.$subPlaceIndex.freeTimeSlots.$day': FieldValue.arrayRemove([
        timeSlot,
      ]),
      // 2. نضيف الساعة في المحجوز
      'subPlaces.$subPlaceIndex.bookedTimeSlots.$day': FieldValue.arrayUnion([
        timeSlot,
      ]),
    });
  }

  // عملية الإلغاء: نرجع الساعة للمتاح
  Future<void> cancelTimeSlot({
    required String placeId,
    required int subPlaceIndex,
    required String day,
    required String timeSlot,
  }) async {
    final docRef = _firestore.collection('places').doc(placeId);

    await docRef.update({
      'subPlaces.$subPlaceIndex.bookedTimeSlots.$day': FieldValue.arrayRemove([
        timeSlot,
      ]),
      'subPlaces.$subPlaceIndex.freeTimeSlots.$day': FieldValue.arrayUnion([
        timeSlot,
      ]),
    });
  }

  Future<void> bookSlots({
    required String placeId,
    required String subPlaceId,
    required Map<String, List<String>> selectedSlots,
    required String userId,
  }) async {
    final DocumentReference placeRef = _firestore
        .collection('places')
        .doc(placeId);

    return await _firestore.runTransaction((transaction) async {
      // جلب بيانات المكان اللحظية
      DocumentSnapshot placeSnapshot = await transaction.get(placeRef);

      if (!placeSnapshot.exists) {
        throw Exception('المكان غير موجود!');
      }

      final placeData = placeSnapshot.data() as Map<String, dynamic>;
      List<dynamic> subPlacesData = List.from(placeData['subPlaces'] ?? []);

      // البحث عن الملعب الفرعي أو الـ Section
      final subPlaceIndex = subPlacesData.indexWhere(
        (sp) => sp['id'] == subPlaceId,
      );
      print(subPlaceId);

      if (subPlaceIndex == -1) {
        throw Exception('الملعب أو القسم غير موجود!');
      }
      print(subPlaceIndex);

      final subPlaceData = subPlacesData[subPlaceIndex];

      // تحويل المواعيد الحالية لـ Maps سهلة التعامل
      Map<String, List<String>> freeTimeSlots = _parseSlots(
        subPlaceData['freeTimeSlots'],
      );
      Map<String, List<String>> bookedTimeSlots = _parseSlots(
        subPlaceData['bookedTimeSlots'],
      );

      // التأكد إن كل المواعيد المطلوبة لسه "متاحة" ومتحجزتش في النص
      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          bool isFree = freeTimeSlots[day]?.contains(slot) ?? false;
          bool isAlreadyBooked = bookedTimeSlots[day]?.contains(slot) ?? false;

          if (!isFree || isAlreadyBooked) {
            throw Exception(
              'للأسف، الساعة $slot في يوم $day طارت وحجزها حد تاني!',
            );
          }
        }
      }

      // تنفيذ الحجز: نقل المواعيد من "المتاحة" إلى "المحجوزة"
      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          freeTimeSlots[day]?.remove(slot);

          if (bookedTimeSlots[day] == null) {
            bookedTimeSlots[day] = [];
          }
          bookedTimeSlots[day]!.add(slot);
          bookedTimeSlots[day]!.sort(); // ترتيب المواعيد
        }
      }

      // تحديث البيانات في Firestore
      subPlacesData[subPlaceIndex]['freeTimeSlots'] = freeTimeSlots;
      subPlacesData[subPlaceIndex]['bookedTimeSlots'] = bookedTimeSlots;
      print(subPlacesData[subPlaceIndex]['bookedTimeSlots']);
      transaction.update(placeRef, {'subPlaces': subPlacesData});
      print("update done");
    });
  }

  // ميثود مساعدة لتحويل البيانات القادمة من Firestore لشكل Map سليم
  Map<String, List<String>> _parseSlots(dynamic data) {
    if (data == null) return {};
    return (data as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
  }

  // 4. إلغاء حجز
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }
}
