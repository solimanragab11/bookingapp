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
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/repos/pricing_repository.dart';
import 'package:hanzbthalk/core/db/app_notification_helper.dart';

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

  Future<PlacesPageResult> getPlacesPaginated({
    required String governorate,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection('places')
          .where('governorate', isEqualTo: governorate.toLowerCase())
          .orderBy('name')
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await query.get();

      final List<PlaceModel> places = snapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      final DocumentSnapshot? lastDoc = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : null;
      final bool hasMore = places.length == limit;

      return PlacesPageResult(
        places: places,
        lastDocument: lastDoc,
        hasMore: hasMore,
      );
    } catch (e) {
      debugPrint("Error fetching paginated places: $e");
      rethrow;
    }
  }

  Future<List<PlaceModel>> getPlacesByGovernorate(String governorate) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('places')
          .where('governorate', isEqualTo: governorate.toLowerCase())
          .get();
      return snapshot.docs
          .map((doc) => PlaceModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching places by governorate: $e");
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

      // Notify owner of new booking
      AppNotificationHelper.notifyOwner(
        placeId: booking.placeId,
        title: 'حجز جديد / New Booking',
        body:
            'تم حجز ملعب جديد بقيمة ${booking.totalPrice} ج.م / A new slot has been booked for ${booking.totalPrice} EGP',
        data: {'bookingId': booking.id, 'placeId': booking.placeId},
      );
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

      final Map<String, dynamic> lockedSlots = Map.from(slots.lockedSlots);
      final now = DateTime.now();

      // التأكد إن كل المواعيد المطلوبة لسه "متاحة" وغير محجوزة مؤقتاً لمستخدم آخر
      for (var entry in selectedSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          bool isFree = freeTimeSlots[day]?.contains(slot) ?? false;

          // التحقق: هل الساعة دي موجودة في أي حجز قديم؟
          bool isAlreadyBooked = bookedTimeSlots.any(
            (b) => b.slots[day]?.contains(slot) ?? false,
          );

          // التحقق من أن الساعة غير محجوزة مؤقتاً من قبل شخص آخر
          final String slotId = '${day}_$slot';
          bool isLockedByOther = false;
          if (lockedSlots.containsKey(slotId)) {
            final lockInfo = Map<String, dynamic>.from(lockedSlots[slotId]);
            final expiresAt = lockInfo['expiresAt'] as Timestamp;
            final lockUserId = lockInfo['userId'] as String;

            if (lockUserId != userId && expiresAt.toDate().isAfter(now)) {
              isLockedByOther = true;
            }
          }

          if (!isFree || isAlreadyBooked || isLockedByOther) {
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

          // Clear the lock for this slot
          final String slotId = '${day}_$slot';
          lockedSlots.remove(slotId);
        }
      }

      // إضافة الحجز الجديد للقائمة
      bookedTimeSlots.add(newBooking);

      final updatedSlots = slots.copyWith(
        freeTimeSlots: freeTimeSlots,
        bookedTimeSlots: bookedTimeSlots,
        lockedSlots: lockedSlots,
      );

      transaction.set(slotsRef, updatedSlots.toJson());
    });
  }

  // 4. إلغاء حجز
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  DateTime? getBookingStartTime(BookingModel booking) {
    try {
      if (booking.timeSlots.isEmpty) return null;
      final String fullDay = booking.timeSlots.keys.first;
      final List<String> slots = booking.timeSlots.values.first;
      if (fullDay.isEmpty || slots.isEmpty) return null;

      final datePart = fullDay.contains(' ') ? fullDay.split(' ').last : "";
      final String rawTimeRange = slots.first.toString();
      final String timePart = rawTimeRange.split('-').first.trim();

      if (datePart.isEmpty || timePart.isEmpty) return null;

      final dateComps = datePart.split('/');
      final timeComps = timePart.split(':');
      if (dateComps.length < 2 || timeComps.isEmpty) return null;

      int year = booking.createdAt.year;

      final int day = int.parse(dateComps[0]);
      final int month = int.parse(dateComps[1]);
      if (dateComps.length >= 3) {
        year = int.parse(dateComps[2]);
      }

      int hour = int.parse(timeComps[0]);
      final int minute = timeComps.length > 1
          ? int.parse(timeComps[1].trim())
          : 0;

      if (hour >= 24) {
        hour = hour % 24;
      }

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      debugPrint("Error parsing booking start time: $e");
      return null;
    }
  }

  Future<void> cancelUserBooking(BookingModel booking) async {
    final slotsRef = _firestore.collection('slots').doc(booking.subPlaceId);

    // Calculate expected refund
    final startTime = getBookingStartTime(booking);
    double expectedRefund = 0.0;
    if (startTime != null) {
      expectedRefund = getIt<PricingRepository>().calculateRefund(
        amountPaidOnline: booking.paidAmount,
        deposit: booking.requiredDeposit,
        bookingStartTime: startTime,
      );
    }

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot slotsSnapshot = await transaction.get(slotsRef);
      if (!slotsSnapshot.exists) return;

      final slots = SlotsModel.fromJson(
        slotsSnapshot.data() as Map<String, dynamic>,
      );

      // Copy freeTimeSlots and bookedTimeSlots
      final Map<String, List<String>> freeTimeSlots = Map.from(
        slots.freeTimeSlots.map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      );
      final List<BookingIdModel> bookedTimeSlots = List.from(
        slots.bookedTimeSlots,
      );

      // Restore free slots and remove booked slots
      for (var entry in booking.timeSlots.entries) {
        String day = entry.key;
        for (String slot in entry.value) {
          if (freeTimeSlots[day] == null) {
            freeTimeSlots[day] = [];
          }
          if (!freeTimeSlots[day]!.contains(slot)) {
            freeTimeSlots[day]!.add(slot);
            freeTimeSlots[day]!.sort();
          }
        }
      }

      // Remove the booking from bookedTimeSlots
      bookedTimeSlots.removeWhere((b) => b.bookingId == booking.id);

      final updatedSlots = slots.copyWith(
        freeTimeSlots: freeTimeSlots,
        bookedTimeSlots: bookedTimeSlots,
      );

      transaction.update(slotsRef, updatedSlots.toJson());

      // If the user paid online, create a refund request document
      if (booking.paidAmount > 0) {
        transaction
            .set(_firestore.collection('refund_requests').doc(booking.id), {
              'id': booking.id,
              'bookingId': booking.id,
              'userId': booking.userId,
              'placeId': booking.placeId,
              'subPlaceId': booking.subPlaceId,
              'amountPaidOnline': booking.paidAmount,
              'expectedRefund': expectedRefund,
              'status': 'pending',
              'createdAt': FieldValue.serverTimestamp(),
              'timeSlots': booking.timeSlots,
            });
      }

      // Delete the booking doc
      transaction.delete(_firestore.collection('bookings').doc(booking.id));
    });

    if (booking.paidAmount > 0) {
      // Notify Admins about the refund request
      AppNotificationHelper.notifyAdmins(
        title: 'طلب استرداد جديد / New Refund Request',
        body:
            'طلب مستخدم استرداد مبلغ ${booking.paidAmount} ج.م لحجز رقم ${booking.id} / A user requested a refund of ${booking.paidAmount} EGP for booking ${booking.id}',
        data: {
          'bookingId': booking.id,
          'userId': booking.userId,
          'amount': booking.paidAmount,
        },
      );

      // Notify Owner that the booking was cancelled (refund requested)
      AppNotificationHelper.notifyOwner(
        placeId: booking.placeId,
        title: 'إلغاء حجز مع طلب استرداد / Booking Cancelled (Refund)',
        body:
            'تم إلغاء الحجز رقم ${booking.id} وتم طلب استرداد مبلغ ${booking.paidAmount} ج.م / Booking ${booking.id} was cancelled with a refund request of ${booking.paidAmount} EGP',
        data: {
          'bookingId': booking.id,
          'placeId': booking.placeId,
          'amount': booking.paidAmount,
        },
      );
    }
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

  // دالة لجلب طلبات الاسترداد الخاصة باليوزر (Raw Data)
  Future<List<Map<String, dynamic>>> getUserRefundRequests(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('refund_requests')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception("error_fetching_refund_requests");
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

  Future<void> decrementPenaltyBookingsLeft(String userId) async {
    try {
      final docRef = _firestore.collection('users').doc(userId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final int penaltyLeft = data['penaltyBookingsLeft'] ?? 0;
          if (penaltyLeft > 0) {
            transaction.update(docRef, {
              'penaltyBookingsLeft': penaltyLeft - 1,
            });
          }
        }
      });
    } catch (e) {
      debugPrint("Error decrementing penaltyBookingsLeft: $e");
    }
  }

  Future<void> registerNoShow({
    required String bookingId,
    required String userId,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    final bookingSnapshot = await bookingRef.get();
    if (!bookingSnapshot.exists) return;

    final booking = BookingModel.fromJson(
      bookingSnapshot.data() as Map<String, dynamic>,
    );
    final slotsRef = _firestore.collection('slots').doc(booking.subPlaceId);

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      int currentPoints = 0;
      int currentNoShow = 0;
      int currentPenalty = 0;

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        currentPoints = userData['points'] ?? 0;
        currentNoShow = userData['noShowCount'] ?? 0;
        currentPenalty = userData['penaltyBookingsLeft'] ?? 0;
      }

      final int newPoints = (currentPoints - 20).clamp(0, 9999999);
      final int newNoShow = currentNoShow + 1;
      int newPenalty = currentPenalty;
      if (newNoShow >= 2 && currentPenalty == 0) {
        newPenalty = 3;
      }

      transaction.update(userRef, {
        'points': newPoints,
        'noShowCount': newNoShow,
        'penaltyBookingsLeft': newPenalty,
      });

      final slotsSnapshot = await transaction.get(slotsRef);
      if (slotsSnapshot.exists) {
        final slots = SlotsModel.fromJson(
          slotsSnapshot.data() as Map<String, dynamic>,
        );

        final Map<String, List<String>> freeTimeSlots = Map.from(
          slots.freeTimeSlots.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          ),
        );
        final List<BookingIdModel> bookedTimeSlots = List.from(
          slots.bookedTimeSlots,
        );

        for (var entry in booking.timeSlots.entries) {
          String day = entry.key;
          for (String slot in entry.value) {
            if (freeTimeSlots[day] == null) {
              freeTimeSlots[day] = [];
            }
            if (!freeTimeSlots[day]!.contains(slot)) {
              freeTimeSlots[day]!.add(slot);
              freeTimeSlots[day]!.sort();
            }
          }
        }

        bookedTimeSlots.removeWhere((b) => b.bookingId == booking.id);

        final updatedSlots = slots.copyWith(
          freeTimeSlots: freeTimeSlots,
          bookedTimeSlots: bookedTimeSlots,
        );
        transaction.update(slotsRef, updatedSlots.toJson());
      }

      transaction.delete(bookingRef);
    });
  }
}
