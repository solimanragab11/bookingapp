import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_states.dart';
import 'package:uuid/uuid.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingService _bookingService;
  final AuthService _authService;
  PlaceModel? _place;
  SubPlace? _subPlace;

  BookingCubit(this._bookingService, this._authService)
    : super(BookingInitial());

  // 1. تهيئة الحجز
  void initializeBooking({
    required PlaceModel place,
    required SubPlace subPlace,
  }) {
    _place = place;
    _subPlace = subPlace;
    final firstDay = subPlace.freeTimeSlots.keys.firstOrNull;

    emit(
      BookingDataState(
        selectedDay: firstDay,
        selectedBookingSlots: {},
        originalTotalAmount: 0.0,
        finalAmount: 0.0,
        paidAmount: 0.0,
        remainingAmount: 0.0,
        isOffer: false,
        usedPoints: 0,
        pricePerhour: subPlace.pricePerHour.toDouble(),
      ),
    );
  }

  // 2. تحديث الداتا لما الـ StreamBuilder يلقط تغيير من Firestore
  void updateLiveSubPlace(SubPlace newSubPlace) {
    _subPlace = newSubPlace;
    if (state is BookingDataState) {
      final currentState = state as BookingDataState;
      emit(currentState.copyWith());
    }
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

  // 4. اختيار/إلغاء ساعة (Slot)
  void toggleTimeSlot(String slotId) {
    if (state is BookingDataState && _subPlace != null) {
      final currentState = state as BookingDataState;
      final updatedSlots = Set<String>.from(currentState.selectedBookingSlots);
      double updatedOriginalPrice = currentState.originalTotalAmount;

      if (updatedSlots.contains(slotId)) {
        updatedSlots.remove(slotId);
        updatedOriginalPrice -= _subPlace!.pricePerHour;
      } else {
        updatedSlots.add(slotId);
        updatedOriginalPrice += _subPlace!.pricePerHour;
      }

      _calculateAndEmit(
        currentState: currentState,
        newOriginalPrice: updatedOriginalPrice,
        newSlots: updatedSlots,
        isOffer: currentState.isOffer,
        points: currentState.usedPoints,
      );
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
      emit(
        currentState.copyWith(
          paidAmount: amount,
          remainingAmount: (currentState.finalAmount - amount).clamp(
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
    // قاعدة الخصم: كل نقطة بـ 1%
    double discountFactor = isOffer ? (points / 100) : 0.0;
    double newFinalAmount = newOriginalPrice * (1 - discountFactor);

    // حساب العربون بناءً على عدد الساعات
    double deposit = _calculateDeposit(newSlots.length);

    emit(
      currentState.copyWith(
        originalTotalAmount: newOriginalPrice,
        finalAmount: newFinalAmount,
        selectedBookingSlots: newSlots,
        isOffer: isOffer,
        usedPoints: points,
        minRequiredDeposit: deposit,
        requiredDeposit: deposit,
        // لو المبلغ المكتوب أكبر من السعر الجديد، بننزله للسعر الجديد
        paidAmount: currentState.paidAmount > newFinalAmount
            ? newFinalAmount
            : currentState.paidAmount,
        remainingAmount: (newFinalAmount - currentState.paidAmount).clamp(
          0.0,
          double.infinity,
        ),
      ),
    );
  }

  double _calculateDeposit(int count) =>
      count == 0 ? 0.0 : (((count + 2) ~/ 3) * 100).toDouble();

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
        bookingDate: DateTime.now(),
        timeSlots: slotsToBook,
        totalPrice: currentState.originalTotalAmount,
        paidAmount: amountToPay,
        requiredDeposit: currentState.requiredDeposit,
        isOffer: currentState.isOffer, // دي اللي كانت بتوصل false
        priceAfterOffer: currentState.finalAmount,
        placeId: _place!.id,
        isCash: false,
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
        pointsToAdd: 5,
        userId: userId,
      );

      emit(BookingSuccess(message: 'bookingSuccessMessage'));
    } catch (e) {
      print(e);
      emit(BookingFailure(errorMessage: 'error_occurred'));
    }
  }
}
