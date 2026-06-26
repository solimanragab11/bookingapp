import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/core/repos/pricing_repository.dart';
import 'package:hanzbthalk/features/user/booking/cubit/booking_states.dart';
import 'package:hanzbthalk/core/db/app_notification_helper.dart';
import 'package:hanzbthalk/features/user/booking/services/slot_lock_service.dart';
import 'package:uuid/uuid.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingService _bookingService;
  final AuthService _authService;
  final PricingRepository _pricingRepository;
  final SlotLockService _slotLockService;
  PlaceModel? _place;
  SubPlaceModel? _subPlace;

  StreamSubscription? _subPlaceSubscription;
  StreamSubscription? _slotsSubscription;

  BookingCubit(
    this._bookingService,
    this._authService,
    this._pricingRepository,
    this._slotLockService,
  ) : super(BookingInitial());

  // 1. تهيئة الحجز
  void initializeBooking({
    required PlaceModel place,
    required SubPlaceModel subPlace,
  }) {
    _place = place;
    _subPlace = subPlace;

    emit(
      BookingDataState(
        place: place,
        liveSubPlace: subPlace,
        selectedBookingSlots: const {},
        originalTotalAmount: 0.0,
        finalAmount: 0.0,
        paidAmount: 0.0,
        remainingAmount: 0.0,
        isOffer: false,
        usedPoints: 0,
        userPoints: 0,
        pricePerhour: subPlace.pricePerHour.toDouble(),
      ),
    );

    // Fetch user details asynchronously and update the state
    _authService.getCurrentUser().then((user) {
      if (user != null && state is BookingDataState) {
        final currentState = state as BookingDataState;
        final updatedState = currentState.copyWith(
          userPoints: user.points,
          noShowCount: user.noShowCount,
          penaltyBookingsLeft: user.penaltyBookingsLeft,
        );
        emit(updatedState);
        _calculateAndEmit(
          currentState: updatedState,
          newOriginalPrice: updatedState.originalTotalAmount,
          newSlots: updatedState.selectedBookingSlots,
          isOffer: updatedState.isOffer,
          points: updatedState.usedPoints,
        );
      }
    });

    // Watch subplace updates
    _subPlaceSubscription?.cancel();
    _subPlaceSubscription = _bookingService
        .getSubPlaceStream(place.id, subPlace.id)
        .listen(
          (newSubPlace) {
            _subPlace = newSubPlace;
            if (state is BookingDataState) {
              final currentState = state as BookingDataState;
              emit(
                currentState.copyWith(
                  liveSubPlace: newSubPlace,
                  pricePerhour: newSubPlace.pricePerHour.toDouble(),
                ),
              );
            }
          },
          onError: (error) {
            debugPrint(
              "❌ BookingCubit: Error watching subplace for ID '${subPlace.id}': $error",
            );
            emit(BookingFailure(errorMessage: 'error_occurred'));
          },
        );

    // Watch slots updates
    final slotsId = subPlace.slotsIds.isNotEmpty
        ? subPlace.slotsIds.first
        : subPlace.id;
    _slotsSubscription?.cancel();
    _slotsSubscription = _bookingService
        .watchSlots(slotsId)
        .listen(
          (newSlots) {
            if (state is BookingDataState) {
              final currentState = state as BookingDataState;
              final currentSelectedDay =
                  currentState.selectedDay ??
                  newSlots.freeTimeSlots.keys.firstOrNull;
              emit(
                currentState.copyWith(
                  slots: newSlots,
                  selectedDay: currentSelectedDay,
                ),
              );
            }
          },
          onError: (error) {
            debugPrint(
              "❌ BookingCubit: Error watching slots for ID '$slotsId': $error",
            );
            emit(BookingFailure(errorMessage: 'noSlotsAvailable'));
          },
        );
  }

  // 2. تحديث الداتا لما الـ StreamBuilder يلقط تغيير من Firestore
  void updateLiveSubPlace(SubPlaceModel newSubPlace) {
    _subPlace = newSubPlace;
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;
      emit(currentState.copyWith());
    }
  }

  @override
  Future<void> close() {
    _subPlaceSubscription?.cancel();
    _slotsSubscription?.cancel();
    return super.close();
  }

  // 3. اختيار اليوم (بيصفر الساعات المختارة)
  void selectDay(String day) {
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;
      emit(
        currentState.copyWith(
          selectedDay: day,
          selectedBookingSlots: {},
          originalTotalAmount: 0.0,
          finalAmount: 0.0,
          paidAmount: 0.0,
          remainingAmount: 0.0,
        ),
      );
    }
  }

  // 4. اختيار/إلغاء ساعة (Slot) مع القفل المؤقت (Optimistic UI Updates)
  Future<void> selectSlot(String slotId) async {
    if (state is! BookingDataState || _subPlace == null) return;
    final currentState = state as BookingDataState;

    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      emit(BookingFailure(errorMessage: 'user_not_authenticated'));
      return;
    }

    final isSelected = currentState.selectedBookingSlots.contains(slotId);

    if (isSelected) {
      // --- Deselecting (Optimistic Update) ---
      // 1. Instantly update the UI
      final updatedSlots = Set<String>.from(currentState.selectedBookingSlots)..remove(slotId);
      final double updatedOriginalPrice = currentState.originalTotalAmount - _subPlace!.pricePerHour;

      _calculateAndEmit(
        currentState: currentState,
        newOriginalPrice: updatedOriginalPrice,
        newSlots: updatedSlots,
        isOffer: currentState.isOffer,
        points: currentState.usedPoints,
      );

      // 2. Perform database operation in the background
      try {
        await _slotLockService.releaseLockSlot(
          subPlaceId: _subPlace!.id,
          slotId: slotId,
          userId: userId,
        );
      } catch (e) {
        debugPrint("❌ BookingCubit: Error releasing lock in background: $e");
      }
      return;
    }

    // --- Selecting (Optimistic Update) ---
    // 1. Instantly update the UI (assume success)
    final updatedSlots = Set<String>.from(currentState.selectedBookingSlots)..add(slotId);
    final double updatedOriginalPrice = currentState.originalTotalAmount + _subPlace!.pricePerHour;

    _calculateAndEmit(
      currentState: currentState,
      newOriginalPrice: updatedOriginalPrice,
      newSlots: updatedSlots,
      isOffer: currentState.isOffer,
      points: currentState.usedPoints,
    );

    // Emit temporary optimistic success state so snackbar/animations can trigger
    emit(SlotLockSuccess(
      messageKey: 'one_minute_to_pay',
      dataState: state as BookingDataState,
    ));

    // 2. Perform Firestore transaction in the background
    try {
      final success = await _slotLockService.tryLockSlot(
        subPlaceId: _subPlace!.id,
        slotId: slotId,
        userId: userId,
        durationMinutes: 1,
      );

      if (!success) {
        // --- Revert Optimistic Update on Failure ---
        if (state is BookingDataState) {
          final freshState = state as BookingDataState;
          final revertedSlots = Set<String>.from(freshState.selectedBookingSlots)..remove(slotId);
          final double revertedOriginalPrice = freshState.originalTotalAmount - _subPlace!.pricePerHour;

          _calculateAndEmit(
            currentState: freshState,
            newOriginalPrice: revertedOriginalPrice,
            newSlots: revertedSlots,
            isOffer: freshState.isOffer,
            points: freshState.usedPoints,
          );

          emit(SlotLockFailure(
            errorMessageKey: 'slot_taken_by_other',
            dataState: state as BookingDataState,
          ));
        }
      }
    } catch (e) {
      // --- Revert Optimistic Update on Exception ---
      debugPrint("❌ BookingCubit: Exception locking slot: $e");
      if (state is BookingDataState) {
        final freshState = state as BookingDataState;
        final revertedSlots = Set<String>.from(freshState.selectedBookingSlots)..remove(slotId);
        final double revertedOriginalPrice = freshState.originalTotalAmount - _subPlace!.pricePerHour;

        _calculateAndEmit(
          currentState: freshState,
          newOriginalPrice: revertedOriginalPrice,
          newSlots: revertedSlots,
          isOffer: freshState.isOffer,
          points: freshState.usedPoints,
        );

        emit(SlotLockFailure(
          errorMessageKey: 'slot_taken_by_other',
          dataState: state as BookingDataState,
        ));
      }
    }
  }

  // تمديد القفل إلى 10 دقائق قبل البدء في الدفع
  Future<bool> proceedToPayment() async {
    if (state is! BookingDataState || _subPlace == null) return false;
    final currentState = state as BookingDataState;

    final userId = await _authService.getCurrentUserId();
    if (userId == null) {
      emit(BookingFailure(errorMessage: 'user_not_authenticated'));
      return false;
    }

    final slotIds = currentState.selectedBookingSlots.toList();
    if (slotIds.isEmpty) return false;

    // Try to extend locks for all selected slots to 10 minutes
    final success = await _slotLockService.tryLockSlots(
      subPlaceId: _subPlace!.id,
      slotIds: slotIds,
      userId: userId,
      durationMinutes: 10,
    );

    if (success) {
      emit(PaymentLockSuccess(
        messageKey: 'ten_minutes_to_pay',
        dataState: currentState,
      ));
      return true;
    } else {
      emit(PaymentLockFailure(
        errorMessageKey: 'lock_expired',
        dataState: currentState,
      ));
      return false;
    }
  }

  // 5. تفعيل أو إغلاق العرض (الـ Toggle)
  void toggleOffer(bool isEnabled) {
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;

      // لو قفل العرض، بنبعت النقاط بـ 0 عشان السعر يرجع لأصله
      _calculateAndEmit(
        currentState: currentState,
        newOriginalPrice: currentState.originalTotalAmount,
        newSlots: currentState.selectedBookingSlots,
        isOffer: isEnabled,
        points: isEnabled ? currentState.usedPoints : 0,
      );
    }
  }

  // 6. تحريك السلايدر (تغيير النقاط)
  void updateUsedPoints(int points) {
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;
      _calculateAndEmit(
        currentState: currentState,
        newOriginalPrice: currentState.originalTotalAmount,
        newSlots: currentState.selectedBookingSlots,
        isOffer: true, // طالما حرك السلايدر يبقى فعل العرض
        points: points,
      );
    }
  }

  // 7. تحديث المبلغ المدفوع يدوياً
  void updatePaidAmount(double amount) {
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;
      final int noShow = currentState.noShowCount;
      final int penaltyLeft = currentState.penaltyBookingsLeft;

      double minBound;
      double maxBound;

      if (penaltyLeft > 0) {
        minBound = currentState.finalAmount;
        maxBound = currentState.finalAmount;
      } else if (noShow == 1) {
        minBound = currentState.minRequiredDeposit;
        maxBound = currentState.finalAmount;
      } else {
        minBound = currentState.minRequiredDeposit;
        maxBound = currentState.finalAmount;
      }

      final double clampedAmount = amount.clamp(minBound, maxBound);

      emit(
        currentState.copyWith(
          paidAmount: clampedAmount,
          remainingAmount: (currentState.finalAmount - clampedAmount).clamp(
            0.0,
            double.infinity,
          ),
        ),
      );
    }
  }

  // --- الهيلبر الأساسي للحسابات ---
  void _calculateAndEmit({
    required BookingDataState currentState,
    required double newOriginalPrice,
    required Set<String> newSlots,
    required bool isOffer,
    required int points,
  }) {
    double newFinalAmount = _pricingRepository.calculateDiscountedPrice(
      originalPrice: newOriginalPrice,
      points: points,
      isOffer: isOffer,
    );

    // حساب العربون بناءً على عدد الساعات
    double deposit = _pricingRepository.calculateRequiredDeposit(
      slotCount: newSlots.length,
      isOwner: false,
    );

    final int noShow = currentState.noShowCount;
    final int penaltyLeft = currentState.penaltyBookingsLeft;

    double finalAmount;
    double minRequiredDeposit;
    double paidAmount;

    if (penaltyLeft > 0) {
      // Level 3: 100% price + 50 LE fine, flexible payment disabled
      finalAmount = newFinalAmount + 50.0;
      minRequiredDeposit = newFinalAmount + 50.0;
      paidAmount = newFinalAmount + 50.0;
    } else if (noShow == 1) {
      // Level 2: flexible payment allowed + 50 LE fine
      finalAmount = newFinalAmount + 50.0;
      minRequiredDeposit = deposit + 50.0;
      paidAmount = currentState.paidAmount;
      if (paidAmount < minRequiredDeposit) {
        paidAmount = minRequiredDeposit;
      } else if (paidAmount > finalAmount) {
        paidAmount = finalAmount;
      }
    } else {
      // Level 1: normal flexible payment
      finalAmount = newFinalAmount;
      minRequiredDeposit = deposit;
      paidAmount = currentState.paidAmount;
      if (paidAmount < minRequiredDeposit) {
        paidAmount = minRequiredDeposit;
      } else if (paidAmount > finalAmount) {
        paidAmount = finalAmount;
      }
    }

    emit(
      currentState.copyWith(
        originalTotalAmount: newOriginalPrice,
        finalAmount: finalAmount,
        selectedBookingSlots: newSlots,
        isOffer: isOffer,
        usedPoints: points,
        minRequiredDeposit: minRequiredDeposit,
        requiredDeposit: deposit,
        paidAmount: paidAmount,
        remainingAmount: (finalAmount - paidAmount).clamp(0.0, double.infinity),
      ),
    );
  }

  // جلب رصيد النقاط من الداتابيز
  Future<int> getUserPoints() async {
    try {
      UserModel? user = await _authService.getCurrentUser();
      return user?.points ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // تأكيد الحجز النهائي
  Future<void> confirmBooking({required double amountToPay}) async {
    // التأكد إننا في الحالة الصح اللي شايلة بيانات العرض
    if (state is! BookingDataState) return;

    final currentState = state as BookingDataState;

    final userId = await _authService.getCurrentUserId() ?? 'user Id';

    final orderId = Uuid().v4();

    try {
      final Map<String, List<String>> slotsToBook = {};
      for (var id in currentState.selectedBookingSlots) {
        final parts = id.split('_');
        slotsToBook.putIfAbsent(parts[0], () => []).add(parts[1]);
      }
      // 1. حجز الساعات
      await _bookingService.bookSlots(
        placeId: _place!.id,
        subPlaceId: _subPlace!.id,
        selectedSlots: slotsToBook,
        userId: userId,
        orderId: orderId,
      );

      // 2. إنشاء الموديل (تأكد من تمرير currentState.isOffer)
      final model = BookingModel(
        bookedBy: "user",
        id: orderId,
        userId: userId,
        subPlaceId: _subPlace!.id,
        createdAt: DateTime.now(),
        timeSlots: slotsToBook,
        totalPrice: currentState.originalTotalAmount,
        paidAmount: amountToPay,
        requiredDeposit: currentState.requiredDeposit,
        isOffer: currentState.isOffer, // دي اللي كانت بتوصل false
        priceAfterOffer: currentState.finalAmount,
        placeId: _place!.id,
        isCash: false,
        status: 'active',
        checkInTime: '',
      );

      await _bookingService.addBooking(model);

      // 3. خصم النقاط لو فيه عرض
      if (currentState.isOffer && currentState.usedPoints > 0) {
        await _bookingService.deductPoints(
          userId: userId,
          pointsToDeduct: currentState.usedPoints,
        );
      }

      await _bookingService.addPointsToUserWithId(
        pointsToAdd: _pricingRepository.calculatePointsToAdd(
          finalPrice: currentState.finalAmount,
        ),
        userId: userId,
      );

      if (currentState.penaltyBookingsLeft > 0) {
        await _bookingService.decrementPenaltyBookingsLeft(userId);
      }

      // Schedule/refresh local reminders immediately for user's bookings
      try {
        final bookings = await _bookingService.getUserBookings(userId);
        List<Map<String, dynamic>> enrichedBookings = [];
        for (var b in bookings) {
          final pId = b['placeId'];
          if (pId != null) {
            final placeData = await _bookingService.getPlaceById(pId);
            if (placeData != null) {
              b['placeInfo'] = placeData.toJson();
            }
          }
          enrichedBookings.add(b);
        }
        await AppNotificationHelper.scheduleRemindersForUser(enrichedBookings, userId);
        debugPrint('[BookingCubit] confirmBooking — Scheduled reminders for user successfully.');
      } catch (ne) {
        debugPrint('⚠️ [BookingCubit] confirmBooking failed to schedule reminders: $ne');
      }

      emit(BookingSuccess(message: 'bookingSuccessMessage'));
    } catch (e) {
      emit(BookingFailure(errorMessage: 'error_occurred'));
    }
  }
}
