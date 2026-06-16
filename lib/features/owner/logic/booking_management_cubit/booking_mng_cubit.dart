import 'dart:async';
import 'package:intl/intl.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/repos/pricing_repository.dart';
import 'package:hanzbthalk/features/owner/repos/owner_repo_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_states.dart';
import 'package:uuid/uuid.dart';

class ManageBookingPlaceCubit extends Cubit<ManageBookingPlaceState> {
  final OwnerRepoImpl _ownerRepository;
  final PricingRepository _pricingRepository;
  StreamSubscription? _placesSubscription;
  List<PlaceModel> places = [];
  ManageBookingPlaceCubit(this._ownerRepository, this._pricingRepository)
    : super(ManagePlaceInitial());

  // ---------------------------------------------------------------------------
  // Fetch owner places — live stream
  // ---------------------------------------------------------------------------

  Future<void> getMyPlacesOnce() async {
    emit(ManagePlaceLoading('from palces loading'));
    // 2. نادى الدالة واستنى النتيجة
    final result = await _ownerRepository.getMyPlacesOnce();
    // 3. افتح الصندوق (الـ Either)
    result.fold(
      (failureMessage) {
        // لو العملية فشلت (الجانب الأيسر - Left)
        // بنبعت رسالة الخطأ للـ State
        emit(ManagePlaceError(failureMessage));
      },
      (placesList) async {
        // لو العملية نجحت (الجانب الأيمن - Right)
        // بنبعت قائمة الأماكن للـ UI
        places = placesList;
        emit(ManagePlaceLoaded(places: places));
      },
    );
  }

  Future<void> addManualBooking({
    required String placeId,
    required String subPlaceId,
    required List<String> selectedSlots,
    required String userPhone,
    required DateTime bookingDate,
    required double pricePerHour,
    required double deposit,
  }) async {
    // 1. حماية: لو الكوبيت مقفول متنفذش حاجة
    if (isClosed) return;

    try {
      // إرسال حالة التحميل (لو عندك State للتحميل)
      emit(ManagePlaceLoading('from the booking man.'));

      final String dayKey = _formatBookingDate(bookingDate);
      final Map<String, List<String>> formattedSlots = {dayKey: selectedSlots};
      final double totalPrice = selectedSlots.length * pricePerHour;

      final String? userId = await _ownerRepository.getUserIdByPhone(userPhone);

      final booking = BookingModel(
        bookedBy: 'owner',
        id: const Uuid().v4(),
        userId: userId ?? 'unknown_user',
        subPlaceId: subPlaceId,
        createdAt: DateTime.now(),
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

      // 2. التنفيذ الفعلي في Firebase
      await _ownerRepository.bookSlots(
        subPlaceId: subPlaceId,
        placeId: placeId,
        selectedSlots: formattedSlots,
        booking: booking,
        userId: userId ?? 'guest_user',
      );

      // 3. تأكد إن الكوبيت لسه "عايش" بعد الـ await الطويل بتاع Firebase
      if (!isClosed) {
        emit(ManagePlaceOperationSuccess());

        // 4. التحديث التلقائي للبيانات
        // ملاحظة: لو getMyPlacesOnce بتاخد وقت، يفضل متعملش await ليها
        // عشان متأخرش الـ Success state اللي هتقفل الـ Dialog أو الصفحة
        getMyPlacesOnce();
      }
    } catch (e) {
      debugPrint('[ManageBookingPlaceCubit] Error: $e');
      if (!isClosed) {
        emit(ManagePlaceError('error_occurred'));
      }
    }
  }
  // ---------------------------------------------------------------------------
  // Cancel / Delete Booking
  // ---------------------------------------------------------------------------

  Future<void> cancelManualBooking({
    required String placeId,
    required int subPlaceIndex,
    required DateTime bookingDate,
    required List<String> slots,
  }) async {
    // 1. أول حاجة لازم نطلع الـ Loading
    emit(ManagePlaceLoading('from canceling '));

    final String dayKey = _formatBookingDate(bookingDate);

    // 2. تنفيذ العملية
    final result = await _ownerRepository.cancelBooking(
      placeId: placeId,
      subPlaceIndex: subPlaceIndex,
      dayKey: dayKey,
      slotsToCancel: slots,
    );

    // 3. معالجة النتيجة
    await result.fold(
      (failureMessage) async {
        emit(ManagePlaceError(failureMessage));
        // حتى في الفشل، لازم نرجع الحالة لـ Loaded عشان الـ Loading يختفي
        await getMyPlacesOnce();
      },
      (_) async {
        // الترتيب هنا "جوهري" يا بطل:

        // أولاً: نجيب الداتا الجديدة فعلياً من السيرفر
        await getMyPlacesOnce();

        // ثانياً: نبعت نجاح العملية عشان الـ SnackBar تظهر
        emit(ManagePlaceOperationSuccess());

        // ثالثاً: نبعت الـ Loaded بالداتا الجديدة عشان الـ UI يرسم نفسه والـ Loading يختفي
        emit(ManagePlaceLoaded(places: places));
      },
    );
  }

  // ميثود مساعدة لفصل منطق التنسيق
  String _formatBookingDate(DateTime date) {
    return DateFormat('EEEE dd/MM', 'en').format(date).toLowerCase();
  }

  // ---------------------------------------------------------------------------
  // Delete place
  // ---------------------------------------------------------------------------
  Future<bool> deletePlace({
    required String placeId,
    required String ownerId,
  }) async {
    try {
      final result = await _ownerRepository.deletePlaceWithImages(
        placeId: placeId,
        ownerId: ownerId,
      );
      return result.fold((errorKey) {
        if (!isClosed) emit(ManagePlaceError(errorKey));
        return false;
      }, (_) => true);
    } catch (e) {
      debugPrint('[ManageBookingPlaceCubit] deletePlace error: $e');
      if (!isClosed) emit(ManagePlaceError('deletePlaceError'));
      return false;
    }
  }

  @override
  Future<void> close() {
    _placesSubscription?.cancel();
    return super.close();
  }
}
