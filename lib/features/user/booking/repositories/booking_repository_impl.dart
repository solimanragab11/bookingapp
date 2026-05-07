// data/repositories/booking_repository_impl.dart
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/repositories/booking_repository.dart';

// features/user/booking/repositories/booking_repository_impl.dart
class BookingRepositoryImpl implements IBookingRepository {
  final BookingService _bookingService;
  final AuthService _authService;
  BookingRepositoryImpl(this._bookingService, this._authService);

  @override
  Stream<SubPlace> watchSubPlace(String placeId, String subPlaceId) {
    return _bookingService.getSubPlaceStream(placeId, subPlaceId);
  }

  @override
  Future<void> processBooking({
    required BookingModel booking,
    required int pointsToDeduct,
    required String orderId,
  }) async {
    // 1. حجز المواعيد (Atomic Transaction)
    await _bookingService.bookSlots(
      placeId: booking.placeId,
      subPlaceId: booking.subPlaceId,
      selectedSlots: booking.timeSlots,
      userId: booking.userId,
      orderId: orderId,
    );

    // 2. إضافة سجل الحجز
    await _bookingService.addBooking(booking);

    // 3. إدارة النقاط
    if (pointsToDeduct > 0) {
      await _bookingService.deductPoints(
        userId: booking.userId,
        pointsToDeduct: pointsToDeduct,
      );
    }

    // إضافة نقاط مكافأة للحجز
    await _bookingService.addPointsToUserWithId(
      userId: booking.userId,
      pointsToAdd: 5,
    );
  }

  @override
  Future<List<PlaceModel>> fetchAllPlaces() => _bookingService.getAllPlaces();

  @override
  Future<void> confirmUserBooking({
    required BookingModel booking,
    required int pointsToDeduct,
    required String orderId,
  }) async {
    try {
      // 1. تحديث الـ Slots في الـ SubPlace (حجز الساعات لحظياً)
      await _bookingService.bookSlots(
        placeId: booking.placeId,
        subPlaceId: booking.subPlaceId,
        selectedSlots: booking.timeSlots,
        userId: booking.userId,
        orderId: orderId,
      );

      // 2. إضافة الحجز نفسه في كولكشن الـ Bookings
      await _bookingService.addBooking(booking);

      // 3. خصم النقاط لو اليوزر استخدم عرض
      if (pointsToDeduct > 0) {
        await _bookingService.deductPoints(
          userId: booking.userId,
          pointsToDeduct: pointsToDeduct,
        );
      }

      // 4. مكافأة: إضافة 5 نقاط لعمي السولي مع كل حجز جديد
      await _bookingService.addPointsToUserWithId(
        userId: booking.userId,
        pointsToAdd: 5,
      );
    } catch (e) {
      // لو حاجة فشلت بنرمي الـ Error عشان الـ Cubit يلقطه ويعرضه لليوزر
      throw Exception("فشل في إتمام الحجز: ${e.toString()}");
    }
  }

  @override
  Future<int> fetchUserPoints() async {
    try {
      // بنجيب اليوزر الحالي من الـ AuthService
      final user = await _authService.getCurrentUser();

      if (user != null) {
        // بنرجع النقاط من موديل اليوزر
        return user.points;
      }
      return 0;
    } catch (e) {
      debugPrint("Error fetching points: $e");
      return 0; // في حالة الخطأ بنفترض إن نقاطه 0
    }
  }
}
