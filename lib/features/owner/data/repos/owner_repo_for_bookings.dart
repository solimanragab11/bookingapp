import 'package:cloud_firestore/cloud_firestore.dart'; // ضفنا دي عشان الـ Transaction والـ Snapshot
import 'package:dartz/dartz.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';

class OwnerBookingRepository {
  final FirestoreOwnerService _firestoreService;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // بنستخدم الـ instance هنا للـ Transaction

  OwnerBookingRepository(this._firestoreService);

  // جلب أماكن المالك
  Stream<Either<String, List<Place>>> getMyPlaces(String ownerId) async* {
    try {
      yield* _firestoreService
          .getOwnerPlaces(ownerId)
          .map((places) => Right<String, List<Place>>(places));
    } catch (e) {
      yield Left<String, List<Place>>("فشل في جلب الأماكن: ${e.toString()}");
    }
  }

  // جلب التحليلات
  Future<Either<String, Map<String, dynamic>>> getPlaceWithAnalysis(
    String placeId,
  ) async {
    try {
      final analysis = await _firestoreService.getPlaceAnalysis(placeId);
      return Right(analysis);
    } catch (e) {
      return Left("فشل في تحميل التحليلات");
    }
  }

  // حذف مكان وصوره بدون المساس بالحجوزات (تاريخ مالي مهم)
  Future<Either<String, Unit>> deletePlaceWithImages({
    required String placeId,
    required String ownerId,
  }) async {
    try {
      await _firestoreService.deletePlaceWithImages(
        placeId: placeId,
        ownerId: ownerId,
      );
      return const Right(unit);
    } catch (e) {
      return Left('فشل في حذف المكان: ${e.toString()}');
    }
  }

  // ميثود الحجز الجماعي (المتصلحة)
  Future<void> bookMultipleSlots({
    required String placeId,
    required int subPlaceIndex,
    required String day,
    required List<String> slots,
    required bool isCanceling,
  }) async {
    // الوصول للـ Doc بيكون من الـ _firestore مباشرة
    final docRef = _firestore.collection('places').doc(placeId);

    return await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("المكان غير موجود");

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> subPlaces = List.from(data['subPlaces'] ?? []);

      // تأكد إن الـ index موجود
      if (subPlaceIndex >= subPlaces.length)
        throw Exception("الملعب الفرعي غير موجود");

      Map<String, dynamic> targetSubPlace = Map<String, dynamic>.from(
        subPlaces[subPlaceIndex],
      );

      // تحويل المواعيد الحالية لـ Maps قابلة للتعديل
      Map<String, List<String>> free = _parse(targetSubPlace['freeTimeSlots']);
      Map<String, List<String>> booked = _parse(
        targetSubPlace['bookedTimeSlots'],
      );

      for (String slot in slots) {
        if (isCanceling) {
          // إلغاء حجز: شيل من المحجوز ورجع للفاضي
          if (booked[day]?.contains(slot) ?? false) {
            booked[day]?.remove(slot);
            free[day] = (free[day] ?? [])
              ..add(slot)
              ..sort(_compareHours);
          }
        } else {
          // حجز جديد: شيل من الفاضي وحط في المحجوز
          if (free[day]?.contains(slot) ?? false) {
            free[day]?.remove(slot);
            booked[day] = (booked[day] ?? [])
              ..add(slot)
              ..sort(_compareHours);
          }
        }
      }

      // تحديث المصفوفة المحلية
      subPlaces[subPlaceIndex]['freeTimeSlots'] = free;
      subPlaces[subPlaceIndex]['bookedTimeSlots'] = booked;

      // رفع المصفوفة كاملة لـ Firestore لضمان عدم مسح الأيام الأخرى
      transaction.update(docRef, {'subPlaces': subPlaces});
    });
  }

  // ترتيب المواعيد زمنياً
  int _compareHours(String a, String b) {
    try {
      int hourA = int.parse(a.split(':')[0]);
      int hourB = int.parse(b.split(':')[0]);
      return hourA.compareTo(hourB);
    } catch (e) {
      return 0; // في حالة وجود "Dash" أو شكل مختلف
    }
  }

  // محول البيانات
  Map<String, List<String>> _parse(dynamic data) {
    if (data == null) return {};
    return (data as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, List<String>.from(v ?? [])),
    );
  }
}
