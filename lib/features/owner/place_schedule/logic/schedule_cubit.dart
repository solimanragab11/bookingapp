import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_id_model.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_impl.dart';
import 'package:uuid/uuid.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final FirestoreOwnerService _ownerService;
  final OwnerRepoImpl _ownerRepository;
  StreamSubscription? _placeSubscription;

  ScheduleCubit(this._ownerService, this._ownerRepository)
    : super(ScheduleState.initial());

  // ---------------------------------------------------------------------------
  // 1. مراقبة المكان لحظة بلحظة (Live Stream)
  // ---------------------------------------------------------------------------
  void startWatchingPlace(String placeId) {
    emit(state.copyWith(status: ScheduleStatus.loading));

    _placeSubscription?.cancel();
    _placeSubscription = _ownerService
        .listenToPlaceById(placeId)
        .listen(
          (updatedPlace) {
            emit(
              state.copyWith(
                currentPlace: updatedPlace,
                status: ScheduleStatus.liveUpdate,
              ),
            );
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: ScheduleStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  // ---------------------------------------------------------------------------
  // 2. إضافة حجز يدوي (Manual Booking)
  // ---------------------------------------------------------------------------
  Future<void> addManualBooking({
    required String placeId,
    required String subPlaceId,
    required List<String> selectedSlots,
    required String userPhone,
    required DateTime bookingDate,
    required double pricePerHour,
    required double deposit,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.loading));

    try {
      final String dayKey = _formatBookingDate(bookingDate);
      final Map<String, List<String>> formattedSlots = {dayKey: selectedSlots};
      final double totalPrice = selectedSlots.length * pricePerHour;

      // البحث عن UserId برقم التليفون
      final String? userId = await _ownerRepository.getUserIdByPhone(userPhone);

      final booking = BookingModel(
        bookedBy: 'owner',
        id: const Uuid().v4(),
        userId: userId ?? 'unknown_user',
        subPlaceId: subPlaceId,
        createdAt: bookingDate,
        timeSlots: formattedSlots,
        totalPrice: totalPrice,
        paidAmount: deposit,
        requiredDeposit: _calculateRequiredDeposit(selectedSlots.length),
        isOffer: false,
        priceAfterOffer: totalPrice,
        placeId: placeId,
        isCash: true,
      );

      // التنفيذ في Firebase
      await _ownerRepository.bookSlots(
        subPlaceId: subPlaceId,
        placeId: placeId,
        selectedSlots: formattedSlots,
        booking: booking,
        userId: userId ?? 'guest_user',
      );

      emit(state.copyWith(status: ScheduleStatus.actionSuccess));
      clearSelection(); // مسح التحديد بعد النجاح
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 3. إلغاء حجز (Cancel Booking)
  // ---------------------------------------------------------------------------
  Future<void> cancelManualBooking({
    required String placeId,
    required int subPlaceIndex,
    required DateTime bookingDate,
    required List<String> slots,
  }) async {
    emit(state.copyWith(status: ScheduleStatus.loading));

    final String dayKey = _formatBookingDate(bookingDate);

    try {
      await _ownerRepository.cancelBooking(
        placeId: placeId,
        subPlaceIndex: subPlaceIndex,
        dayKey: dayKey,
        slotsToCancel: slots,
      );

      emit(state.copyWith(status: ScheduleStatus.actionSuccess));
      clearSelection();
    } catch (e) {
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 4. منطق الـ UI (Selection Logic)
  // ---------------------------------------------------------------------------
  void selectDate(DateTime date) =>
      emit(state.copyWith(selectedDate: date, selectedSlots: []));

  void selectSubPlace(int index) =>
      emit(state.copyWith(selectedSubPlaceIndex: index, selectedSlots: []));

  void clearSelection() => emit(
    state.copyWith(
      selectedSlots: [],
      activeBookingId: () => null,
      isSelectingBooked: () => false,
    ),
  );

  void toggleSlot(
    String clickedSlot,
    bool isBooked, {
    required PlaceModel place,
  }) {
    if (isBooked) {
      _handleBookedSlotToggle(clickedSlot, place);
    } else {
      _handleManualSlotToggle(clickedSlot);
    }
  }

  void _handleBookedSlotToggle(String clickedSlot, PlaceModel place) {
    final dayKey = _getCurrentDayKey();
    final subPlace = place.subPlaces[state.selectedSubPlaceIndex];

    // البحث عن الحجز المرتبط بالساعة
    final targetBooking = subPlace.bookedTimeSlots.firstWhere(
      (b) => b.slots[dayKey]?.contains(clickedSlot) ?? false,
      orElse: () => BookingIdModel(
        bookingId: '',
        bookedBy: '',
        bookername: '',
        slots: {},
      ), // يفضل يكون عندك static method للـ empty model
    );

    if (targetBooking.bookingId.isEmpty) return;

    // تنفيذ الـ Toggle
    if (state.activeBookingId == targetBooking.bookingId) {
      _clearFullSelection();
    } else {
      _selectFullBooking(targetBooking, dayKey);
    }
  }

  void _handleManualSlotToggle(String clickedSlot) {
    final List<String> currentSlots = List<String>.from(state.selectedSlots);

    if (currentSlots.contains(clickedSlot)) {
      currentSlots.remove(clickedSlot);
    } else {
      currentSlots.add(clickedSlot);
    }

    emit(
      state.copyWith(
        selectedSlots: currentSlots,
        activeBookingId: () => null, // تصفير الـ ID عشان نضمن الـ Toggle يشتغل
        isSelectingBooked: () => false,
      ),
    );
  }

  void _selectFullBooking(BookingIdModel booking, String dayKey) {
    final List<String> relatedSlots = booking.slots[dayKey] ?? [];
    emit(
      state.copyWith(
        selectedSlots: relatedSlots,
        activeBookingId: () => booking.bookingId,
        isSelectingBooked: () => true,
      ),
    );
  }

  void _clearFullSelection() {
    emit(
      state.copyWith(
        selectedSlots: [],
        activeBookingId: () => null,
        isSelectingBooked: () => false,
      ),
    );
  }

  String _getCurrentDayKey() {
    return DateFormat('EEEE dd/MM').format(state.selectedDate).toLowerCase();
  }

  // ميثود خاصة للإضافة - فصل المنطق بيخلي الكود أنظف بكتير

  // ميثود خاصة للإزالة

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _formatBookingDate(DateTime date) =>
      DateFormat('EEEE dd/MM', 'en').format(date).toLowerCase();

  double _calculateRequiredDeposit(int numberOfSlots) =>
      (numberOfSlots / 2) * 50;

  @override
  Future<void> close() {
    _placeSubscription?.cancel();
    return super.close();
  }
}
