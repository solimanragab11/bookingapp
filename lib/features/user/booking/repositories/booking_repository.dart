// domain/repositories/booking_repository.dart
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';

abstract class IBookingRepository {
  Stream<SubPlaceModel> watchSubPlace(String placeId, String subPlaceId);
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
