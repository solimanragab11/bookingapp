import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  // جلب كل الأماكن لكل المستخدمين (عشان الصفحة الرئيسية)
  Future<List<PlaceModel>> getAllPlaces() async {
    try {
      // بنجيب الداتا من كولكشن places
      QuerySnapshot snapshot = await _firestore.collection('places').get();

      // تحويل الداتا لموديل Place
      return snapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching all places: $e");
      rethrow;
    }
  }

  Future<List<SubPlaceModel>> getAllSubPlaces() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('subplaces').get();
      return snapshot.docs
          .map(
            (doc) => SubPlaceModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint("Error fetching all subplaces: $e");
      return [];
    }
  }

  // 1. إضافة حجز جديد
  Future<void> addBooking(BookingModel booking) async {
    try {
      debugPrint(booking.paidAmount.toString());

      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toJson());
    } catch (e) {
      debugPrint('Error addinhereeeeeeeeeeeeg booking: $e');
      rethrow;
    }
  }

  // 3. العملية المعقدة: التأكد من التوافر وحجز الوقت (Atomic Transaction)
  Future<void> bookSlots({
    required String placeId,
    required String subPlaceId,
    required Map<String, List<String>> selectedSlots,
    required String userId,
    required String orderId,
  }) async {
    final DocumentReference slotsRef = _firestore
        .collection('slots')
        .doc(subPlaceId);

    return await _firestore.runTransaction((transaction) async {
      DocumentSnapshot slotsSnapshot = await transaction.get(slotsRef);

      if (!slotsSnapshot.exists) {
        throw Exception('schedule_not_found');
      }

      final slots = SlotsModel.fromJson(
        slotsSnapshot.data() as Map<String, dynamic>,
      );

      // Copy lists to mutate
      final Map<String, List<String>> freeTimeSlots = Map.from(
        slots.freeTimeSlots.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      );
      final List<BookingIdModel> bookedTimeSlots = List.from(
        slots.bookedTimeSlots,
      );

      final UserModel? user = await _auth.getCurrentUser();

      // التأكد إن كل المواعيد المطلوبة لسه "متاحة"
      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          bool isFree = freeTimeSlots[day]?.contains(slot) ?? false;

          // التحقق: هل الساعة دي موجودة في أي حجز قديم؟
          bool isAlreadyBooked = bookedTimeSlots.any(
            (b) => b.slots[day]?.contains(slot) ?? false,
          );

          if (!isFree || isAlreadyBooked) {
            throw const SlotAlreadyBookedException('msg_already_booked');
          }
        }
      }

      // تنفذ الحجز: نقل المواعيد
      BookingIdModel newBooking = BookingIdModel(
        bookingId: orderId,
        slots: selectedSlots,
        bookedBy: 'user',
        bookername: user?.username ?? 'unknown',
      );

      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          freeTimeSlots[day]?.remove(slot);
        }
      }

      // إضافة الحجز الجديد للقائمة
      bookedTimeSlots.add(newBooking);

      final updatedSlots = slots.copyWith(
        freeTimeSlots: freeTimeSlots,
        bookedTimeSlots: bookedTimeSlots,
      );

      transaction.set(slotsRef, updatedSlots.toJson());
    });
  }

  // 4. إلغاء حجز
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  // 1. دالة لجلب حجوزات اليوزر فقط (Raw Data)
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception("error_fetching_bookings");
    }
  }

  // 2. دالة لجلب بيانات مكان محدد بواسطة الـ ID
  Future<PlaceModel?> getPlaceById(String placeId) async {
    try {
      final doc = await _firestore.collection('places').doc(placeId).get();
      return doc.exists
          ? PlaceModel.fromJson(doc.data() as Map<String, dynamic>)
          : null;
    } catch (e) {
      debugPrint("خطأ أثناء جلب بيانات المكان $placeId: $e");
      return null;
    }
  }

  Future<List<PlaceModel>> getPlacesByName(String placeName) async {
    try {
      // 1. بنجيب كل الوثائق المتطابقة مع البحث
      final querySnapshot = await _firestore
          .collection('places')
          .where('name', isGreaterThanOrEqualTo: placeName)
          .where('name', isLessThanOrEqualTo: '$placeName\uf8ff')
          .get();
      // 2. بنحول كل وثيقة جوه اللستة لـ PlaceModel ونرجعهم كلهم في List
      return querySnapshot.docs.map((doc) {
        return PlaceModel.fromJson(doc.data());
      }).toList();
    } catch (e) {
      debugPrint("خطأ أثناء جلب قائمة الملاعب باسم $placeName: $e");
      return []; // لو حصل خطأ بنرجع لستة فاضية عشان الـ UI ما يضربش كراش
    }
  }

  Future<List<PlaceModel>> getPlacesByCat(String cat) async {
    try {
      // 1. بنجيب كل الوثائق المتطابقة مع البحث
      final querySnapshot = await _firestore
          .collection('places')
          .where('type', isEqualTo: cat)
          .get();
      // 2. بنحول كل وثيقة جوه اللستة لـ PlaceModel ونرجعهم كلهم في List
      return querySnapshot.docs.map((doc) {
        return PlaceModel.fromJson(doc.data());
      }).toList();
    } catch (e) {
      debugPrint("خطأ أثناء جلب قائمة الملاعب باسم $cat: $e");
      return []; // لو حصل خطأ بنرجع لستة فاضية عشان الـ UI ما يضربش كراش
    }
  }

  Future<void> addPointsToUserWithId({
    required String userId,
    required int pointsToAdd,
  }) async {
    try {
      // الوصول لمرجع اليوزر في كوليكشن users
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      // تحديث النقاط باستخدام increment لضمان الدقة البرمجية
      await userRef.update({'points': FieldValue.increment(pointsToAdd)});
    } catch (e) {
      rethrow; // عشان لو حابب تعمله catch في الـ UI وتظهر رسالة خطأ
    }
  }

  Future<void> deductPoints({
    required String userId,
    required int pointsToDeduct,
  }) async {
    if (pointsToDeduct <= 0) return; // مفيش حاجة تتخصم

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'points': FieldValue.increment(-pointsToDeduct),
      });
    } catch (e) {
      throw Exception("failed_to_update_points");
    }
  }

  // ============ OWNER BOOKING MANAGEMENT ============

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (!doc.exists) return null;
      return BookingModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ خطأ في جلب الحجز: $e');
      rethrow;
    }
  }
  // features/user/booking/services/booking_service.dart

  Stream<SubPlaceModel> getSubPlaceStream(String placeId, String subPlaceId) {
    return _firestore.collection('subplaces').doc(subPlaceId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw const SubPlaceNotFoundException("SubPlace not found");
      }
      return SubPlaceModel.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  Stream<SlotsModel> watchSlots(String slotsId) {
    return _firestore.collection('slots').doc(slotsId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception("Slots not found");
      }
      return SlotsModel.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  Future<List<SlotsModel>> getAllSlots() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('slots').get();
      return snapshot.docs
          .map((doc) => SlotsModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching all slots: $e");
      return [];
    }
  }
}
