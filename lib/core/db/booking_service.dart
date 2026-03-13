import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // جلب كل الأماكن لكل المستخدمين (عشان الصفحة الرئيسية)
  Future<List<Place>> getAllPlaces() async {
    try {
      // بنجيب الداتا من كولكشن places
      QuerySnapshot snapshot = await _firestore.collection('places').get();

      // تحويل الداتا لموديل Place
      return snapshot.docs
          .map((doc) => Place.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching all places: $e");
      rethrow;
    }
  }

  // 1. إضافة حجز جديد
  Future<void> addBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toJson());
    } catch (e) {
      print('Error adding booking: $e');
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
      print('Error getting bookings: $e');
      rethrow;
    }
  }

  // 3. العملية المعقدة: التأكد من التوافر وحجز الوقت في خطوة واحدة (Atomic Transaction)
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
      if (subPlaceIndex == -1) {
        throw Exception('الملعب أو القسم غير موجود!');
      }

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
}
