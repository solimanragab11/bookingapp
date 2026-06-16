import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/db/firestore_owner_service.dart';
import 'package:hanzbthalk/features/owner/repos/owner_repo_for_bookings.dart';

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
          return const Left("error_fetching_data");
        });
  }

  Stream<Either<String, List<PlaceModel>>> getMySubPlacesStream() {
    return ownerService
        .getOwnerPlaces()
        .map<Either<String, List<PlaceModel>>>((places) => Right(places))
        .handleError((e) {
          return const Left("error_fetching_data");
        });
  }

  Stream<Either<String, List<PlaceModel>>> getMySlotsStream() {
    return ownerService
        .getOwnerPlaces()
        .map<Either<String, List<PlaceModel>>>((places) => Right(places))
        .handleError((e) {
          return const Left("error_fetching_data");
        });
  }

  // --- جلب الأماكن (Future لمرة واحدة) ---

  @override
  Future<Either<String, Unit>> addPlace(PlaceModel place) async {
    try {
      await ownerService.addPlace(place);
      return Right(unit);
    } catch (e) {
      return const Left("failed_to_add_place");
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
      return const Left("failed_to_delete_place");
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
      return const Left("failed_to_update_data");
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
      return const Left("failed_to_load_analytics");
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
      debugPrint('🔥 [repo.bookSlots] Calling ownerService.bookSlots...');
      // تنفيذ العمليتين Atomic من خلال السيرفس
      await ownerService.bookSlots(
        placeId: placeId,
        subPlaceId: subPlaceId.toString(),
        selectedSlots: selectedSlots,
        userId: userId,
        orderId: booking.id,
      );
      debugPrint('🔥 [repo.bookSlots] Slots updated. Now calling addBooking...');
      await ownerService.addBooking(booking);
      debugPrint('✅ [repo.bookSlots] addBooking succeeded. Returning Right.');
      return Right(unit);
    } catch (e) {
      debugPrint('❌ [repo.bookSlots] FAILED: $e');
      return Left(e.toString()); // إرجاع الخطأ الحقيقي بدل رسالة عامة
    }
  }

  @override
  Future<String?> getUserIdByPhone(String phoneNumber) async {
    try {
      debugPrint('📞 [getUserIdByPhone] Raw input: $phoneNumber');
      phoneNumber = '+2$phoneNumber';
      debugPrint('📞 [getUserIdByPhone] Querying Firestore with: $phoneNumber');
      final userId = await ownerService.getUserIdByPhoneNumber(phoneNumber);
      debugPrint('📞 [getUserIdByPhone] Result: $userId');
      return userId; // سيرجع null لو مش موجود
    } catch (e) {
      debugPrint('❌ Error in getUserIdByPhone: $e');
      return null; // إرجاع null بدل من 'error_occurred' عشان الحجز مايفشلش
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
      return const Left("failed_to_fetch_your_places");
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
