import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/cubit/user_bookings_status.dart';

class UserBookingsCubit extends Cubit<UserBookingsState> {
  final BookingService _service;
  UserBookingsCubit(this._service) : super(UserBookingsInitial());

  Future<void> fetchMyBookings(String userId) async {
    emit(UserBookingsLoading());
    try {
      // نداء الدالة الأولى: جلب الحجوزات
      final bookings = await _service.getUserBookings(userId);

      if (bookings.isEmpty) {
        emit(UserBookingsEmpty());
        return;
      }

      // نداء الدالة الثانية لكل حجز لدمج بيانات المكان
      List<Map<String, dynamic>> enrichedBookings = [];

      for (var booking in bookings) {
        final placeId = booking['placeId'];
        if (placeId != null) {
          final PlaceModel placeData =
              await _service.getPlaceById(placeId) as PlaceModel;
          booking['placeInfo'] = placeData.toJson(); // دمج البيانات هنا
        } else {}
        enrichedBookings.add(booking);
      }

      emit(UserBookingsSuccess(enrichedBookings));
    } catch (e) {
      emit(UserBookingsFailure(e.toString()));
    }
  }
}
