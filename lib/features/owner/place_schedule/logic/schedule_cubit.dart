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
import 'package:hanzbthalk/features/user/booking/services/slot_lock_service.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final FirestoreOwnerService _ownerService;
  final OwnerRepoImpl _ownerRepository;
  final PricingRepository _pricingRepository;
  final SlotLockService _slotLockService;
  StreamSubscription? _placeSubscription;
  StreamSubscription? _slotsSubscription;

  ScheduleCubit(
    this._ownerService,
    this._ownerRepository,
    this._pricingRepository,
    this._slotLockService,
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
    debugPrint(
      '📅 [addManualBooking] userPhone=$userPhone bookingDate=$bookingDate',
    );
    debugPrint(
      '📅 [addManualBooking] selectedSlots=$selectedSlots pricePerHour=$pricePerHour deposit=$deposit',
    );

    try {
      final String dayKey = _formatBookingDate(bookingDate);
      debugPrint('📅 [addManualBooking] dayKey=$dayKey');

      final Map<String, List<String>> formattedSlots = {dayKey: selectedSlots};
      final double totalPrice = selectedSlots.length * pricePerHour;
      debugPrint(
        '📅 [addManualBooking] totalPrice=$totalPrice formattedSlots=$formattedSlots',
      );

      // البحث عن UserId برقم التليفون
      debugPrint(
        '📅 [addManualBooking] Looking up userId for phone: $userPhone',
      );
      final String? userId = await _ownerRepository.getUserIdByPhone(userPhone);
      debugPrint('📅 [addManualBooking] getUserIdByPhone result: $userId');

      final booking = BookingModel(
        bookedBy: 'owner',
        id: const Uuid().v4(),
        userId: userId ?? userPhone,
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
        status: 'active',
        checkInTime: '',
      );
      debugPrint(
        '📅 [addManualBooking] BookingModel created with id=${booking.id} userId=${booking.userId}',
      );

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
            final Set<String> dayKeys = {};
            dayKeys.addAll(slots.freeTimeSlots.keys);
            for (var booking in slots.bookedTimeSlots) {
              dayKeys.addAll(booking.slots.keys);
            }

            DateTime selectedDate = state.selectedDate;

            if (dayKeys.isNotEmpty) {
              final List<DateTime> dates = dayKeys.map((k) => _parseDayKey(k)).toList();
              dates.sort((a, b) => a.compareTo(b));
              
              final hasCurrentDate = dates.any((d) =>
                  d.year == selectedDate.year &&
                  d.month == selectedDate.month &&
                  d.day == selectedDate.day);

              if (!hasCurrentDate) {
                selectedDate = dates.first;
              }
            }

            emit(state.copyWith(
              currentSlots: slots,
              selectedDate: selectedDate,
            ));
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

  Future<void> clearSelection() async {
    final List<String> slotsToRelease = List<String>.from(state.selectedSlots);
    final bool isSelectingBooked = state.isSelectingBooked ?? false;

    emit(
      state.copyWith(
        selectedSlots: [],
        activeBookingId: () => null,
        isSelectingBooked: () => false,
      ),
    );

    if (slotsToRelease.isNotEmpty && !isSelectingBooked) {
      final authService = getIt<AuthService>();
      final userId = await authService.getCurrentUserId();
      if (userId != null && state.subPlaces.isNotEmpty && state.selectedSubPlaceIndex < state.subPlaces.length) {
        final String subPlaceId = state.subPlaces[state.selectedSubPlaceIndex].id;
        final String dayKey = _getCurrentDayKey();
        final List<String> slotIds = slotsToRelease.map((slot) => "${dayKey}_$slot").toList();
        try {
          await _slotLockService.releaseLocks(
            subPlaceId: subPlaceId,
            slotIds: slotIds,
            userId: userId,
          );
        } catch (e) {
          debugPrint("❌ ScheduleCubit: Error releasing locks in clearSelection: $e");
        }
      }
    }
  }

  // تمديد القفل إلى 10 دقائق قبل البدء في الحجز اليدوي
  Future<bool> proceedToManualBooking() async {
    if (state.subPlaces.isEmpty || state.selectedSubPlaceIndex >= state.subPlaces.length) return false;
    final String subPlaceId = state.subPlaces[state.selectedSubPlaceIndex].id;

    final authService = getIt<AuthService>();
    final userId = await authService.getCurrentUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: 'user_not_authenticated',
        ),
      );
      return false;
    }

    final String dayKey = _getCurrentDayKey();
    final List<String> slotIds = state.selectedSlots.map((slot) => "${dayKey}_$slot").toList();
    if (slotIds.isEmpty) return false;

    emit(state.copyWith(status: ScheduleStatus.loading));

    try {
      final success = await _slotLockService.tryLockSlots(
        subPlaceId: subPlaceId,
        slotIds: slotIds,
        userId: userId,
        durationMinutes: 10,
      );

      if (success) {
        emit(state.copyWith(status: ScheduleStatus.liveUpdate));
        return true;
      } else {
        emit(
          state.copyWith(
            status: ScheduleStatus.error,
            errorMessage: 'lock_expired',
          ),
        );
        emit(state.copyWith(status: ScheduleStatus.liveUpdate));
        return false;
      }
    } catch (e) {
      debugPrint("❌ ScheduleCubit: Exception in proceedToManualBooking: $e");
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: 'lock_expired',
        ),
      );
      emit(state.copyWith(status: ScheduleStatus.liveUpdate));
      return false;
    }
  }

  Future<void> toggleSlot(String clickedSlot, bool isBooked) async {
    if (isBooked) {
      _handleBookedSlotToggle(clickedSlot);
    } else {
      await _handleManualSlotToggle(clickedSlot);
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
      ),
    );

    if (targetBooking.bookingId.isEmpty) return;

    // تنفيذ الـ Toggle
    if (state.activeBookingId == targetBooking.bookingId) {
      _clearFullSelection();
    } else {
      _selectFullBooking(targetBooking, dayKey);
    }
  }

  Future<void> _handleManualSlotToggle(String clickedSlot) async {
    final List<String> currentSlots = List<String>.from(state.selectedSlots);
    final String dayKey = _getCurrentDayKey();
    final String slotId = "${dayKey}_$clickedSlot";

    final authService = getIt<AuthService>();
    final userId = await authService.getCurrentUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: ScheduleStatus.error,
          errorMessage: 'user_not_authenticated',
        ),
      );
      return;
    }

    if (state.subPlaces.isEmpty || state.selectedSubPlaceIndex >= state.subPlaces.length) return;
    final String subPlaceId = state.subPlaces[state.selectedSubPlaceIndex].id;

    if (currentSlots.contains(clickedSlot)) {
      // --- Deselecting (Optimistic Update) ---
      currentSlots.remove(clickedSlot);
      emit(
        state.copyWith(
          selectedSlots: currentSlots,
          activeBookingId: () => null,
          isSelectingBooked: () => false,
        ),
      );

      try {
        await _slotLockService.releaseLockSlot(
          subPlaceId: subPlaceId,
          slotId: slotId,
          userId: userId,
        );
      } catch (e) {
        debugPrint("❌ ScheduleCubit: Error releasing owner lock in background: $e");
      }
    } else {
      // --- Selecting (Optimistic Update) ---
      currentSlots.add(clickedSlot);
      emit(
        state.copyWith(
          selectedSlots: currentSlots,
          activeBookingId: () => null,
          isSelectingBooked: () => false,
        ),
      );

      try {
        final success = await _slotLockService.tryLockSlot(
          subPlaceId: subPlaceId,
          slotId: slotId,
          userId: userId,
          durationMinutes: 1,
        );

        if (!success) {
          // --- Revert Optimistic Update ---
          final List<String> freshSlots = List<String>.from(state.selectedSlots)..remove(clickedSlot);
          emit(
            state.copyWith(
              selectedSlots: freshSlots,
              status: ScheduleStatus.error,
              errorMessage: 'slot_taken_by_other',
            ),
          );
          emit(state.copyWith(status: ScheduleStatus.liveUpdate));
        }
      } catch (e) {
        // --- Revert Optimistic Update ---
        debugPrint("❌ ScheduleCubit: Exception locking owner slot: $e");
        final List<String> freshSlots = List<String>.from(state.selectedSlots)..remove(clickedSlot);
        emit(
          state.copyWith(
            selectedSlots: freshSlots,
            status: ScheduleStatus.error,
            errorMessage: 'slot_taken_by_other',
          ),
        );
        emit(state.copyWith(status: ScheduleStatus.liveUpdate));
      }
    }
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
    final slots = state.currentSlots;
    if (slots != null) {
      final dayStr = DateFormat('dd/MM', 'en').format(state.selectedDate);
      for (var key in slots.freeTimeSlots.keys) {
        if (key.endsWith(dayStr)) return key;
      }
      for (var booking in slots.bookedTimeSlots) {
        for (var key in booking.slots.keys) {
          if (key.endsWith(dayStr)) return key;
        }
      }
    }
    return DateFormat('EEEE dd/MM', 'en').format(state.selectedDate).toLowerCase();
  }

  // ميثود خاصة للإضافة - فصل المنطق بيخلي الكود أنظف بكتير

  // ميثود خاصة للإزالة

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  String _formatBookingDate(DateTime date) {
    final slots = state.currentSlots;
    if (slots != null) {
      final dayStr = DateFormat('dd/MM', 'en').format(date);
      for (var key in slots.freeTimeSlots.keys) {
        if (key.endsWith(dayStr)) return key;
      }
      for (var booking in slots.bookedTimeSlots) {
        for (var key in booking.slots.keys) {
          if (key.endsWith(dayStr)) return key;
        }
      }
    }
    return DateFormat('EEEE dd/MM', 'en').format(date).toLowerCase();
  }

  DateTime _parseDayKey(String dayKey) {
    try {
      final parts = dayKey.trim().split(RegExp(r'\s+'));
      if (parts.length < 2) return DateTime.now();

      final dateParts = parts[1].split('/');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);

      final now = DateTime.now();
      int year = now.year;
      if (month < now.month && now.month - month > 6) {
        year += 1;
      } else if (month > now.month && month - now.month > 6) {
        year -= 1;
      }

      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }
}
