import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_status.dart';

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
        }
        
        final subPlaceId = booking['subPlaceId'];
        if (subPlaceId != null) {
          final subPlaceData =
              await getIt<AdminService>().getSubPlaceById(subPlaceId);
          if (subPlaceData != null) {
            booking['subPlaceInfo'] = subPlaceData.toJson();
          }
        }
        
        enrichedBookings.add(booking);
      }

      emit(UserBookingsSuccess(enrichedBookings));
    } catch (e) {
      emit(UserBookingsFailure(e.toString()));
    }
  }
}
