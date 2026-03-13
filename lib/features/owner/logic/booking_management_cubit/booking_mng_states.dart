import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class ManageBookingPlaceState {}

class ManagePlaceInitial extends ManageBookingPlaceState {}

class ManagePlaceLoading extends ManageBookingPlaceState {}

// حالة النجاح العامة (للإضافة مثلاً)
class ManagePlaceSuccess extends ManageBookingPlaceState {
  final String message;
  ManagePlaceSuccess({required this.message});
}

// حالة عرض الأماكن (Loaded)
class ManagePlaceLoaded extends ManageBookingPlaceState {
  final List<Place> places;
  ManagePlaceLoaded({required this.places});
}

// لو المالك لسه مضافش أي مكان
class ManagePlaceEmpty extends ManageBookingPlaceState {}

class ManagePlaceError extends ManageBookingPlaceState {
  final String message;
  ManagePlaceError(this.message);
}
