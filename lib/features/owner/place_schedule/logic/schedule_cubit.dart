import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';
import 'package:hanzbthalk/core/repos/pricing_repository.dart';
import 'package:hanzbthalk/core/db/firestore_owner_service.dart';
import 'package:hanzbthalk/features/owner/repos/owner_repo_impl.dart';
import 'package:uuid/uuid.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final FirestoreOwnerService _ownerService;
  final OwnerRepoImpl _ownerRepository;
  final PricingRepository _pricingRepository;
  StreamSubscription? _placeSubscription;
  StreamSubscription? _slotsSubscription;

  ScheduleCubit(
    this._ownerService,
    this._ownerRepository,
    this._pricingRepository,
  ) : super(ScheduleState.initial());

  // ---------------------------------------------------------------------------
  // 1. مراقبة المكان لحظة بلحظة (Live Stream)
  // ---------------------------------------------------------------------------
  void startWatchingPlace(String placeId) {
    emit(state.copyWith(status: ScheduleStatus.loading));

    _placeSubscription?.cancel();
    _placeSubscription = _ownerService
        .listenToPlaceById(placeId)
        .listen(
          (updatedPlace) async {
            try {
              // 1. لو المكان ملوش ملاعب فرعية لسه، نتجنب الإيرور
              if (updatedPlace.subPlacesIds.isEmpty) {
                emit(
                  state.copyWith(
                    currentPlace: updatedPlace,
                    subPlaces: [],
                    status: ScheduleStatus.liveUpdate,
                  ),
                );
                return;
              }

              final subPlaces = await getIt<AdminService>().getSubPlacesByIds(
                updatedPlace.subPlacesIds,
              );

              emit(
                state.copyWith(
                  currentPlace: updatedPlace,
                  subPlaces: subPlaces,
                  status: ScheduleStatus.liveUpdate,
                ),
              );

              // 🌟 التعديل السحري هنا:
              // لو لسه مجبناش مواعيد، اختار أول ملعب أوتوماتيك عشان الداتا بتاعته تحمل
              if (state.currentSlots == null && subPlaces.isNotEmpty) {
                selectSubPlace(
                  0,
                ); // السطر ده هيشغل _updateSlotsSubscription فوراً
              }
            } catch (error) {
              emit(
                state.copyWith(
                  status: ScheduleStatus.error,
                  errorMessage: error.toString(),
                ),
              );
            }
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
    debugPrint('📅 [addManualBooking] START');
    debugPrint('📅 [addManualBooking] placeId=$placeId subPlaceId=$subPlaceId');
    debugPrint('📅 [addManualBooking] userPhone=$userPhone bookingDate=$bookingDate');
    debugPrint('📅 [addManualBooking] selectedSlots=$selectedSlots pricePerHour=$pricePerHour deposit=$deposit');

    try {
      final String dayKey = _formatBookingDate(bookingDate);
      debugPrint('📅 [addManualBooking] dayKey=$dayKey');

      final Map<String, List<String>> formattedSlots = {dayKey: selectedSlots};
      final double totalPrice = selectedSlots.length * pricePerHour;
      debugPrint('📅 [addManualBooking] totalPrice=$totalPrice formattedSlots=$formattedSlots');

      // البحث عن UserId برقم التليفون
      debugPrint('📅 [addManualBooking] Looking up userId for phone: $userPhone');
      final String? userId = await _ownerRepository.getUserIdByPhone(userPhone);
      debugPrint('📅 [addManualBooking] getUserIdByPhone result: $userId');

      final booking = BookingModel(
        bookedBy: 'owner',
        id: const Uuid().v4(),
        userId: userId ?? 'unknown_user',
        subPlaceId: subPlaceId,
        createdAt: bookingDate,
        timeSlots: formattedSlots,
        totalPrice: totalPrice,
        paidAmount: deposit,
        requiredDeposit: _pricingRepository.calculateRequiredDeposit(
          slotCount: selectedSlots.length,
          isOwner: true,
        ),
        isOffer: false,
        priceAfterOffer: totalPrice,
        placeId: placeId,
        isCash: true,
      );
      debugPrint('📅 [addManualBooking] BookingModel created with id=${booking.id} userId=${booking.userId}');

      // التنفيذ في Firebase
      debugPrint('📅 [addManualBooking] Calling bookSlots...');
      final result = await _ownerRepository.bookSlots(
        subPlaceId: subPlaceId,
        placeId: placeId,
        selectedSlots: formattedSlots,
        booking: booking,
        userId: userId ?? 'guest_user',
      );

      // ❤️ التحقق من النتيجة - المشكلة كانت هنا: الكود كان بيتجاهل الـ Either ويفطر سكسس دايمًا!
      result.fold(
        (errorMessage) {
          debugPrint('❌ [addManualBooking] bookSlots FAILED: $errorMessage');
          emit(
            state.copyWith(
              status: ScheduleStatus.error,
              errorMessage: errorMessage,
            ),
          );
        },
        (_) {
          debugPrint('✅ [addManualBooking] bookSlots SUCCEEDED');
          emit(state.copyWith(status: ScheduleStatus.actionSuccess));
          clearSelection();
        },
      );
    } catch (e) {
      debugPrint('❌ [addManualBooking] EXCEPTION: $e');
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

  void selectSubPlace(int index) {
    emit(state.copyWith(selectedSubPlaceIndex: index, selectedSlots: []));
    if (state.subPlaces.isNotEmpty && index < state.subPlaces.length) {
      _updateSlotsSubscription(state.subPlaces[index].id);
    }
  }

  void _updateSlotsSubscription(String subPlaceId) {
    _slotsSubscription?.cancel();
    _slotsSubscription = getIt<BookingService>()
        .watchSlots(subPlaceId)
        .listen(
          (slots) {
            emit(state.copyWith(currentSlots: slots));
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

  @override
  Future<void> close() {
    _placeSubscription?.cancel();
    _slotsSubscription?.cancel();
    return super.close();
  }

  void clearSelection() => emit(
    state.copyWith(
      selectedSlots: [],
      activeBookingId: () => null,
      isSelectingBooked: () => false,
    ),
  );

  void toggleSlot(String clickedSlot, bool isBooked) {
    if (isBooked) {
      _handleBookedSlotToggle(clickedSlot);
    } else {
      _handleManualSlotToggle(clickedSlot);
    }
  }

  void _handleBookedSlotToggle(String clickedSlot) {
    final dayKey = _getCurrentDayKey();
    final slots = state.currentSlots;
    if (slots == null) return;

    // البحث عن الحجز المرتبط بالساعة
    final targetBooking = slots.bookedTimeSlots.firstWhere(
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
    return DateFormat('EEEE dd/MM', 'en').format(state.selectedDate).toLowerCase();
  }

  // ميثود خاصة للإضافة - فصل المنطق بيخلي الكود أنظف بكتير

  // ميثود خاصة للإزالة

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _formatBookingDate(DateTime date) =>
      DateFormat('EEEE dd/MM', 'en').format(date).toLowerCase();
}
