import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:uuid/uuid.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_states.dart';

class BookingCubit extends Cubit<BookingState> {
  // استخدام الـ Service الجديدة
  final BookingService _bookingService;
  Place? _place;
  SubPlace? _subPlace;

  BookingCubit(this._bookingService) : super(BookingInitial());

  void initializeBooking({required Place place, required SubPlace subPlace}) {
    _place = place;
    _subPlace = subPlace;
    final firstDay = subPlace.freeTimeSlots.keys.firstOrNull;

    emit(
      BookingDataState(
        selectedDay: firstDay,
        selectedBookingSlots: {},
        provisionalTotalPrice: 0.0,
        requiredDeposit: 0.0,
        minRequiredDeposit: 0.0,
        paidAmount: 0.0,
        remainingAmount: 0.0,
      ),
    );
  }

  void selectDay(String day) {
    if (state is BookingDataState) {
      emit(
        (state as BookingDataState).copyWith(
          selectedDay: day,
          selectedBookingSlots: {},
          provisionalTotalPrice: 0.0,
          requiredDeposit: 0.0,
          minRequiredDeposit: 0.0,
          paidAmount: 0.0,
          remainingAmount: 0.0,
        ),
      );
    }
  }

  void toggleTimeSlot(String slotId) {
    if (state is BookingDataState && _subPlace != null) {
      final currentState = state as BookingDataState;
      final updatedSlots = Set<String>.from(currentState.selectedBookingSlots);
      double updatedPrice = currentState.provisionalTotalPrice;

      if (updatedSlots.contains(slotId)) {
        updatedSlots.remove(slotId);
        updatedPrice -= _subPlace!.pricePerHour;
      } else {
        updatedSlots.add(slotId);
        updatedPrice += _subPlace!.pricePerHour;
      }

      final requiredDeposit = _calculateRequiredDeposit(updatedSlots.length);
      final minRequiredDeposit = _calculateMinRequiredDeposit(
        updatedSlots.length,
      );

      emit(
        currentState.copyWith(
          selectedBookingSlots: updatedSlots,
          provisionalTotalPrice: updatedPrice,
          requiredDeposit: requiredDeposit,
          minRequiredDeposit: minRequiredDeposit,
        ),
      );
    }
  }

  /// Calculate required deposit based on the number of hours
  /// Formula: ((hoursCount + 2) ~/ 3) * 100
  double _calculateRequiredDeposit(int hoursCount) {
    if (hoursCount == 0) return 0.0;
    final deposits = ((hoursCount + 2) ~/ 3) * 100;
    return deposits.toDouble();
  }

  /// Calculate minimum required deposit (same formula as above)
  /// Min: 100 EGP per 3 hours
  double _calculateMinRequiredDeposit(int hoursCount) {
    if (hoursCount == 0) return 0.0;
    final minDeposit = ((hoursCount + 2) ~/ 3) * 100;
    return minDeposit.toDouble();
  }

  /// Set the paid amount and calculate remaining amount
  void setFlexiblePaymentAmount(double paidAmount) {
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;
      final remainingAmount = (currentState.provisionalTotalPrice - paidAmount)
          .clamp(0.0, double.infinity);

      emit(
        currentState.copyWith(
          paidAmount: paidAmount,
          remainingAmount: remainingAmount,
        ),
      );
    }
  }

  /// Validate if the paid amount meets the minimum requirement
  bool isValidPaymentAmount(double paidAmount) {
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;
      return paidAmount >= currentState.minRequiredDeposit &&
          paidAmount <= currentState.provisionalTotalPrice;
    }
    return false;
  }

  Future<void> confirmBooking({
    required String userId,
    required double paidAmount,
  }) async {
    if (state is! BookingDataState) return;
    final currentState = state as BookingDataState;

    emit(BookingLoading());
    try {
      final Map<String, List<String>> slotsToBook = {};
      for (var id in currentState.selectedBookingSlots) {
        final parts = id.split('_');
        slotsToBook.putIfAbsent(parts[0], () => []).add(parts[1]);
      }

      // Book slots via service
      await _bookingService.bookSlots(
        placeId: _place!.id,
        subPlaceId: _subPlace!.id,
        selectedSlots: slotsToBook,
        userId: userId,
      );

      final bookingModel = BookingModel(
        id: const Uuid().v4(),
        userId: userId,
        subPlaceId: _subPlace!.id,
        bookingDate: DateTime.now(),
        timeSlots: slotsToBook,
        totalPrice: currentState.provisionalTotalPrice,
        paidAmount: paidAmount,
        requiredDeposit: currentState.requiredDeposit,
        isOffer: _place!.hasOffer ?? false,
        priceAfterOffer: currentState.provisionalTotalPrice,
        placeId: _place!.id,
        isCash: false, // All bookings are now digital (paid via Paymob)
      );

      await _bookingService.addBooking(bookingModel);

      emit(BookingSuccess(message: 'bookingSuccessMessage'));
    } catch (e) {
      emit(BookingFailure(errorMessage: 'error'));
    }
  }
}
