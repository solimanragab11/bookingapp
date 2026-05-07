import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_for_bookings.dart';

class OwnerRepoImpl implements OwnerRepository {
  final FirestoreOwnerService ownerService;

  OwnerRepoImpl(this.ownerService);

  // --- جلب الأماكن (Stream للأداء الحي) ---
  @override
  Stream<Either<String, List<PlaceModel>>> getMyPlacesStream() {
    return ownerService
        .getOwnerPlaces()
        .map<Either<String, List<PlaceModel>>>((places) => Right(places))
        .handleError((e) {
          return Left("حدث خطأ أثناء جلب البيانات: $e");
        });
  }

  // --- جلب الأماكن (Future لمرة واحدة) ---

  @override
  Future<Either<String, Unit>> addPlace(PlaceModel place) async {
    try {
      await ownerService.addPlace(place);
      return Right(unit);
    } catch (e) {
      return Left("فشل إضافة المكان: $e");
    }
  }

  @override
  Future<Either<String, Unit>> deletePlaceWithImages({
    required String placeId,
    required String ownerId,
  }) async {
    try {
      await ownerService.deletePlaceWithImages(
        placeId: placeId,
        ownerId: ownerId,
      );
      return Right(unit);
    } catch (e) {
      return Left("فشل حذف المكان: $e");
    }
  }

  @override
  Future<Either<String, Unit>> updateSubPlace(
    String placeId,
    String subPlaceId,
    Map<String, dynamic> data,
  ) async {
    try {
      await ownerService.updateSubPlaceDetails(placeId, subPlaceId, data);
      return Right(unit);
    } catch (e) {
      return Left("فشل تحديث البيانات: $e");
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getPlaceAnalysis(
    String placeId,
  ) async {
    try {
      final analysis = await ownerService.getPlaceAnalysis(placeId);
      return Right(analysis);
    } catch (e) {
      return Left("فشل تحميل التحليلات: $e");
    }
  }

  @override
  Future<Either<String, Unit>> bookSlots({
    required String placeId,
    required String subPlaceId,
    required Map<String, List<String>> selectedSlots,
    required String userId,
    required BookingModel booking,
  }) async {
    try {
      print('=========================');

      // تنفيذ العمليتين Atomic من خلال السيرفس
      await ownerService.bookSlots(
        placeId: placeId,
        subPlaceId: subPlaceId.toString(),
        selectedSlots: selectedSlots,
        userId: userId,
        orderId: booking.id,
      );
      print('=========================');
      await ownerService.addBooking(booking);
      return Right(unit);
    } catch (e) {
      return Left("فشل تنفيذ عملية الحجز: $e");
    }
  }

  @override
  Future<String?> getUserIdByPhone(String phoneNumber) async {
    try {
      phoneNumber = '+2$phoneNumber';
      final userId = await ownerService.getUserIdByPhoneNumber(phoneNumber);
      print("userId");
      print(phoneNumber);
      print(userId);
      print('userId');
      return userId; // سيرجع null لو مش موجود
    } catch (e) {
      debugPrint("❌ Error in getUserIdByPhone: $e");
      return "error_occurred"; // أو رجع null حسب تفضيلك
    }
  }

  @override
  Future<Either<String, List<PlaceModel>>> getMyPlacesOnce() async {
    try {
      // 1. جلب الداتا من الـ Service اللي أنت لسه كاتبها
      // ملحوظة: اتأكد إن الدالة في السيرفس اسمها getPlacesByOwner
      final List<PlaceModel> places = await ownerService.getPlacesByOwner();

      // 2. التحقق لو القائمة فاضية (اختياري بس مفيد للـ UI)
      if (places.isEmpty) {
        debugPrint("⚠️ No places found for this owner.");
      }

      // 3. إرجاع النتيجة بنجاح
      return Right(places);
    } catch (e) {
      // 4. مسك أي خطأ (مثلاً مشكلة في النت أو فيربيز)
      debugPrint("❌ Error in getMyPlacesOnce: ${e.toString()}");

      // هنا بنرجع رسالة الخطأ مترجمة (ممكن تستخدم context.tr لو متاح هنا أو رسالة ثابتة)
      return Left("فشل في جلب الأماكن الخاصة بك: ${e.toString()}");
    }
  }

  // inside owner_repo_impl.dart

  Future<Either<String, void>> cancelBooking({
    required String placeId,
    required int subPlaceIndex,
    required String dayKey,
    required List<String> slotsToCancel,
  }) async {
    try {
      await ownerService.cancelBookingTransaction(
        placeId: placeId,
        subPlaceIndex: subPlaceIndex,
        dayKey: dayKey,
        slotsToCancel: slotsToCancel,
      );
      return right(null);
    } catch (e) {
      return left(e.toString());
    }
  }
}
