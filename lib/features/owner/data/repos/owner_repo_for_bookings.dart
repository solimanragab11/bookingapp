import 'package:dartz/dartz.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class OwnerRepository {
  // --- إدارة الأماكن (Places Management) ---
  Future<Either<String, Unit>> addPlace(PlaceModel place);
  Stream<Either<String, List<PlaceModel>>> getMyPlacesStream();
  Future<Either<String, List<PlaceModel>>> getMyPlacesOnce();
  Future<Either<String, Unit>> deletePlaceWithImages({
    required String placeId,
    required String ownerId,
  });
  Future<Either<String, Unit>> updateSubPlace(
    String placeId,
    String subPlaceId,
    Map<String, dynamic> data,
  );

  // --- الحجوزات والتحليلات (Bookings & Analysis) ---
  Future<Either<String, Map<String, dynamic>>> getPlaceAnalysis(String placeId);
  Future<Either<String, Unit>> bookSlots({
    required String placeId,
    required String subPlaceId,
    required Map<String, List<String>> selectedSlots,
    required String userId,
    required BookingModel booking,
  });

  // --- وظائف عامة (General Functions) ---
  Future<String?> getUserIdByPhone(String phoneNumber);
}
