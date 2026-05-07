import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_id_model.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

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

  // 2. جلب حجوزات مكان معين (عشان تظهر في الجدول الزجاجي)
  Future<List<Map<String, dynamic>>> getBookingsForPlace(String placeId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('Error getting bookings: $e');
      rethrow;
    }
  }

  // 3. العملية المعقدة: التأكد من التوافر وحجز الوقت في خطوة واحدة (Atomic Transaction)
  // 3. العملية المعقدة: التأكد من التوافر وحجز الوقت (Atomic Transaction)
  Future<void> bookSlots({
    required String placeId,
    required String subPlaceId,
    required Map<String, List<String>> selectedSlots,
    required String userId,
    required String orderId,
  }) async {
    final DocumentReference placeRef = _firestore
        .collection('places')
        .doc(placeId);

    return await _firestore.runTransaction((transaction) async {
      DocumentSnapshot placeSnapshot = await transaction.get(placeRef);

      if (!placeSnapshot.exists) {
        throw Exception('المكان غير موجود!');
      }

      final placeData = placeSnapshot.data() as Map<String, dynamic>;
      List<dynamic> subPlacesData = List.from(placeData['subPlaces'] ?? []);

      final subPlaceIndex = subPlacesData.indexWhere(
        (sp) => sp['id'] == subPlaceId,
      );
      if (subPlaceIndex == -1) {
        throw Exception('الملعب أو القسم غير موجود!');
      }

      final subPlaceData = subPlacesData[subPlaceIndex];

      // --- التعديل هنا: تحويل البيانات للهيكل الجديد ---
      Map<String, List<String>> freeTimeSlots = _parseSlots(
        subPlaceData['freeTimeSlots'],
      );

      // تحويل الـ List القادمة من Firestore لموديلات
      List<BookingIdModel> bookedTimeSlots =
          (subPlaceData['bookedTimeSlots'] as List? ?? [])
              .map(
                (item) => BookingIdModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

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
            throw Exception(
              'للأسف، الساعة $slot في يوم $day طارت وحجزها حد تاني!',
            );
          }
        }
      }
      final UserModel user = await _auth.getCurrentUser() as UserModel;
      // تنفيذ الحجز: نقل المواعيد
      // بنعمل موديل جديد للحجز الحالي
      BookingIdModel newBooking = BookingIdModel(
        bookingId: orderId,
        slots: selectedSlots,
        bookedBy: 'user',
        bookername: user.username,
      );

      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          freeTimeSlots[day]?.remove(slot);
        }
      }

      // إضافة الحجز الجديد للقائمة
      bookedTimeSlots.add(newBooking);

      // تحديث البيانات في Firestore
      subPlacesData[subPlaceIndex]['freeTimeSlots'] = freeTimeSlots;
      // تحويل لستة الموديلات لـ JSON
      subPlacesData[subPlaceIndex]['bookedTimeSlots'] = bookedTimeSlots
          .map((e) => e.toJson())
          .toList();

      transaction.update(placeRef, {'subPlaces': subPlacesData});
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

  // 1. دالة لجلب حجوزات اليوزر فقط (Raw Data)
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception("خطأ أثناء جلب الحجوزات: $e");
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
      debugPrint("خطأ أثناء خصم النقاط: $e");
      throw Exception("فشل في تحديث النقاط");
    }
  }

  // ============ OWNER BOOKING MANAGEMENT ============

  /// إضافة حجز يدوي من قبل المالك (Manual Entry)
  /// الحجز يُعيّن دائماً bookedBy: 'owner'
  Future<void> addOwnerBooking({
    required String bookingId,
    required String placeId,
    required String subPlaceId,
    required DateTime bookingDate,
    required Map<String, List<String>> timeSlots,
    required double totalPrice,
    required double paidAmount,
    required double requiredDeposit,
    required String userId,
    required bool isCash,
  }) async {
    try {
      final booking = BookingModel(
        id: bookingId,
        bookedBy: 'owner', // ✅ Hardcoded for owner-side bookings
        userId: userId,
        subPlaceId: subPlaceId,
        bookingDate: bookingDate,
        timeSlots: timeSlots,
        totalPrice: totalPrice,
        paidAmount: paidAmount,
        requiredDeposit: requiredDeposit,
        isOffer: false,
        offer: null,
        priceAfterOffer: totalPrice,
        placeId: placeId,
        isCash: isCash,
      );

      await _firestore
          .collection('bookings')
          .doc(bookingId)
          .set(booking.toJson());

      debugPrint('✅ تم إضافة الحجز اليدوي بنجاح (bookedBy: owner)');
    } catch (e) {
      debugPrint('❌ خطأ في إضافة الحجز اليدوي: $e');
      rethrow;
    }
  }

  /// حذف حجز مع تطبيق سياسة التقييد
  /// إذا كان bookedBy == 'owner': السماح بالحذف
  /// إذا كان bookedBy == 'user': رفع استثناء مع رسالة خطأ محددة
  Future<bool> cancelBooking({
    required String bookingId,
    required String bookedBy,
  }) async {
    try {
      if (bookedBy == 'user') {
        // ❌ حجوزات التطبيق محمية ولا يمكن حذفها من قبل المالك
        debugPrint('⚠️ محاولة حذف حجز محمي (bookedBy: user) - تم الرفض');
        throw Exception(
          'App-generated bookings can only be managed by system administration.',
        );
      }

      if (bookedBy == 'owner') {
        // ✅ حجوزات المالك يمكن حذفها مباشرة
        await _firestore.collection('bookings').doc(bookingId).delete();
        debugPrint('✅ تم حذف الحجز اليدوي بنجاح (bookedBy: owner)');
        return true;
      }

      throw Exception('Invalid bookedBy value: $bookedBy');
    } catch (e) {
      debugPrint('❌ خطأ في حذف الحجز: $e');
      rethrow;
    }
  }

  /// جلب جميع الحجوزات لمكان معين في شهر محدد حيث bookedBy == 'user'
  /// تُستخدم لتحليل الحجوزات التي تمت عبر التطبيق فقط
  Future<int> countAppBookings({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      // حساب بداية ونهاية الشهر
      final firstDayOfMonth = DateTime(month.year, month.month, 1);
      final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('bookedBy', isEqualTo: 'user') // Only app-generated
          .where('bookingDate', isGreaterThanOrEqualTo: firstDayOfMonth.toUtc())
          .where('bookingDate', isLessThanOrEqualTo: lastDayOfMonth.toUtc())
          .count()
          .get();

      debugPrint(
        '📊 عدد الحجوزات من التطبيق في ${month.month}/${month.year}: ${snapshot.count}',
      );
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ خطأ في عد الحجوزات: $e');
      rethrow;
    }
  }

  /// جلب تفاصيل الحجوزات من التطبيق (user bookings) لشهر معين
  /// للحصول على بيانات تفصيلية للتحليلات
  Future<List<BookingModel>> getAppBookingsForMonth({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final firstDayOfMonth = DateTime(month.year, month.month, 1);
      final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('bookedBy', isEqualTo: 'user')
          .where('bookingDate', isGreaterThanOrEqualTo: firstDayOfMonth.toUtc())
          .where('bookingDate', isLessThanOrEqualTo: lastDayOfMonth.toUtc())
          .get();

      final bookings = snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();

      debugPrint(
        '📊 جلب ${bookings.length} حجز من التطبيق للشهر ${month.month}/${month.year}',
      );
      return bookings;
    } catch (e) {
      debugPrint('❌ خطأ في جلب حجوزات التطبيق: $e');
      rethrow;
    }
  }

  /// جلب حجز بواسطة ID
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

  Stream<SubPlace> getSubPlaceStream(String placeId, String subPlaceId) {
    return _firestore
        .collection('places')
        .doc(placeId)
        .snapshots() // 1. بنراقب الـ Document بتاع الـ Place كله
        .map((snapshot) {
          // 2. بنتأكد إن الداتا موجودة
          if (!snapshot.exists || snapshot.data() == null) {
            throw Exception("Place not found");
          }

          final data = snapshot.data() as Map<String, dynamic>;

          // 3. بنجيب لستة الـ subPlaces
          final List<dynamic> subList = data['subPlaces'] ?? [];

          // 4. بنعمل Filter عشان نطلع الـ subPlace المطلوب بالـ ID
          final updatedData = subList.firstWhere(
            (e) => e['id'] == subPlaceId,
            orElse: () => null,
          );

          if (updatedData == null) {
            throw Exception("SubPlace not found");
          }

          // 5. بنحول الـ Map لموديل SubPlace ونبعته في الـ Stream
          return SubPlace.fromJson(updatedData as Map<String, dynamic>);
        });
  }
}
