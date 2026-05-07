// domain/repositories/booking_repository.dart
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';

abstract class IBookingRepository {
  Stream<SubPlace> watchSubPlace(String placeId, String subPlaceId);
  Future<void> confirmUserBooking({
    required BookingModel booking,
    required int pointsToDeduct,
    required String orderId,
  });
  Future<void> processBooking({
    required BookingModel booking,
    required int pointsToDeduct,
    required String orderId,
  });
  Future<List<PlaceModel>> fetchAllPlaces();

  Future<int> fetchUserPoints();
}
