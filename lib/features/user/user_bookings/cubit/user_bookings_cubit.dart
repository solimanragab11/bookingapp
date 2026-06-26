import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_status.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_time_helper.dart';
import 'package:hanzbthalk/core/db/app_notification_helper.dart';

class UserBookingsCubit extends Cubit<UserBookingsState> {
  final BookingService _service;
  UserBookingsCubit(this._service) : super(UserBookingsInitial());

  Future<void> fetchMyBookings(String userId) async {
    emit(UserBookingsLoading());
    try {
      // نداء الدالة الأولى: جلب الحجوزات وطلبات الاسترداد
      final bookings = await _service.getUserBookings(userId);
      final refundRequests = await _service.getUserRefundRequests(userId);

      if (bookings.isEmpty && refundRequests.isEmpty) {
        emit(UserBookingsEmpty());
        return;
      }

      // نداء الدالة الثانية لكل حجز لدمج بيانات المكان
      List<Map<String, dynamic>> enrichedBookings = [];
      for (var booking in bookings) {
        final placeId = booking['placeId'];
        if (placeId != null) {
          final PlaceModel? placeData = await _service.getPlaceById(placeId);
          if (placeData != null) {
            booking['placeInfo'] = placeData.toJson(); // دمج البيانات هنا
          }
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

      // ترتيب الحجوزات: النشطة والمعلقة أولاً (تصاعدياً حسب وقت البدء)، ثم الباقي (تنازلياً حسب وقت البدء)
      enrichedBookings.sort((a, b) {
        final statusA = (a['status'] as String? ?? 'active').toLowerCase();
        final statusB = (b['status'] as String? ?? 'active').toLowerCase();

        final isAUpcoming = statusA == 'active' || statusA == 'pending_no_show';
        final isBUpcoming = statusB == 'active' || statusB == 'pending_no_show';

        if (isAUpcoming && !isBUpcoming) return -1;
        if (!isAUpcoming && isBUpcoming) return 1;

        final timeA = BookingTimeHelper.getBookingStartTime(a) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timeB = BookingTimeHelper.getBookingStartTime(b) ?? DateTime.fromMillisecondsSinceEpoch(0);

        if (isAUpcoming) {
          return timeA.compareTo(timeB);
        } else {
          return timeB.compareTo(timeA);
        }
      });

      // دمج بيانات المكان لطلبات الاسترداد أيضاً
      List<Map<String, dynamic>> enrichedRefunds = [];
      for (var refund in refundRequests) {
        final placeId = refund['placeId'];
        if (placeId != null) {
          final PlaceModel? placeData = await _service.getPlaceById(placeId);
          if (placeData != null) {
            refund['placeInfo'] = placeData.toJson();
          }
        }

        final subPlaceId = refund['subPlaceId'];
        if (subPlaceId != null) {
          final subPlaceData =
              await getIt<AdminService>().getSubPlaceById(subPlaceId);
          if (subPlaceData != null) {
            refund['subPlaceInfo'] = subPlaceData.toJson();
          }
        }

        enrichedRefunds.add(refund);
      }

      // Schedule/refresh upcoming match reminders for active user bookings
      AppNotificationHelper.scheduleRemindersForUser(enrichedBookings, userId);

      emit(UserBookingsSuccess(enrichedBookings, enrichedRefunds));
    } catch (e) {
      emit(UserBookingsFailure(e.toString()));
    }
  }

  Future<void> cancelBooking({
    required Map<String, dynamic> bookingData,
    required String userId,
    required double expectedRefund,
  }) async {
    emit(UserBookingsLoading());
    try {
      final booking = BookingModel.fromJson(bookingData);
      await _service.cancelUserBooking(booking);
      emit(UserBookingsCancelSuccess(expectedRefund));
      await fetchMyBookings(userId);
    } catch (e) {
      emit(UserBookingsCancelFailure(e.toString()));
      await fetchMyBookings(userId);
    }
  }
}
