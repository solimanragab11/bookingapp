import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';

abstract class ManageBookingPlaceState {}

// ---------------------------------------------------------------------------
// Screen-level states (drive the main UI)
// ---------------------------------------------------------------------------

class ManagePlaceInitial extends ManageBookingPlaceState {}

/// Full-screen loading — shown only on the very first fetch.
class ManagePlaceLoading extends ManageBookingPlaceState {
  final String msg;
  ManagePlaceLoading(this.msg);
}

/// At least one place exists and is ready to display.
class ManagePlaceLoaded extends ManageBookingPlaceState {
  final List<PlaceModel> places;
  ManagePlaceLoaded({required this.places});

  // ضيف السطرين دول عشان الـ Bloc يحس بالتغيير فعلاً
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagePlaceLoaded &&
          runtimeType == other.runtimeType &&
          places == other.places;

  @override
  int get hashCode => places.hashCode;
}

/// Owner has no places yet.
class ManagePlaceEmpty extends ManageBookingPlaceState {}

/// Something went wrong. [message] is a localization key.
class ManagePlaceError extends ManageBookingPlaceState {
  final String message;
  ManagePlaceError(this.message);
}

// ---------------------------------------------------------------------------
// Operation states (book / cancel / delete)
// Used for lightweight feedback without replacing the place list on screen.
// The BlocListener in the UI handles these; BlocBuilder ignores them.
// ---------------------------------------------------------------------------

/// A slot booking or cancellation is in progress.
class ManagePlaceOperationLoading extends ManageBookingPlaceState {}

/// A slot booking or cancellation completed successfully.
/// The real-time stream will push an updated [ManagePlaceLoaded] automatically.
class ManagePlaceOperationSuccess extends ManageBookingPlaceState {}

// ---------------------------------------------------------------------------
// Analytics states
// ---------------------------------------------------------------------------

class FetchBookingsLoading extends ManageBookingPlaceState {}

class FetchBookingsSuccess extends ManageBookingPlaceState {
  final List<BookingModel> bookings;
  final int appBookingCount;
  final int ownerBookingCount;
  final double totalAppBookingRevenue;

  FetchBookingsSuccess({
    required this.bookings,
    required this.appBookingCount,
    required this.ownerBookingCount,
    required this.totalAppBookingRevenue,
  });
}

class FetchBookingsFailure extends ManageBookingPlaceState {
  final String message;
  FetchBookingsFailure({required this.message});
}

class BookingsLoaded extends ManageBookingPlaceState {
  final List<BookingModel> bookings;
  BookingsLoaded(this.bookings);
}
