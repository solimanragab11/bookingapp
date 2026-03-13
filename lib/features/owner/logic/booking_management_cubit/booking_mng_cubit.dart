import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_for_bookings.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_states.dart';

class ManageBookingPlaceCubit extends Cubit<ManageBookingPlaceState> {
  final OwnerBookingRepository _ownerRepository;

  ManageBookingPlaceCubit(this._ownerRepository) : super(ManagePlaceInitial());

  // 1. جلب أماكن المالك (Stream)
  void fetchMyPlaces(String ownerId) {
    emit(ManagePlaceLoading());

    // الـ Stream ده هو "الرادار" بتاعنا، أي تغيير في السيرفر هيسمع هنا فوراً
    _ownerRepository.getMyPlaces(ownerId).listen((result) {
      result.fold((error) => emit(ManagePlaceError(error)), (places) {
        if (places.isEmpty) {
          emit(ManagePlaceEmpty());
        } else {
          emit(ManagePlaceLoaded(places: places));
        }
      });
    });
  }

  // 2. الميثود الجديدة للحجز الجماعي (Bulk Update)
  Future<void> updateSlotsBulk({
    required String placeId,
    required int subPlaceIndex,
    required String day,
    required List<String> slots,
    required bool isCanceling,
  }) async {
    try {
      // بنعمل Loading خفيف عشان المستخدم يعرف إن فيه عملية بتتم
      // ملاحظة: لو مش عايز الشاشة كلها "تبيض"، ممكن تعمل State تانية للـ Button Loading

      await _ownerRepository.bookMultipleSlots(
        placeId: placeId,
        subPlaceIndex: subPlaceIndex,
        day: day,
        slots: slots,
        isCanceling: isCanceling,
      );

      // مفيش داعي ننادي fetchMyPlaces يدوياً لأننا شغالين بـ Stream
      // بس لو حبيت تتأكد، ممكن تناديها.
      print("Bulk Update Success: ${slots.length} slots updated.");
    } catch (e) {
      emit(ManagePlaceError("فشل التحديث الجماعي: $e"));
    }
  }

  // 3. حذف مكان مع صوره بدون المساس بالحجوزات
  Future<bool> deletePlace({
    required String placeId,
    required String ownerId,
  }) async {
    try {
      final result = await _ownerRepository.deletePlaceWithImages(
        placeId: placeId,
        ownerId: ownerId,
      );
      return result.fold(
        (error) {
          emit(ManagePlaceError(error));
          return false;
        },
        (_) {
          // إحنا شغالين بـ Stream في fetchMyPlaces، فمجرد حذف الداتا
          // هيخلي الـ Stream يحدث الليست تلقائياً
          return true;
        },
      );
    } catch (e) {
      emit(ManagePlaceError('فشل حذف المكان: $e'));
      return false;
    }
  }

  // 3. تحديث التحليلات (اختياري)
  Future<void> refreshAnalysis(String placeId) async {
    final result = await _ownerRepository.getPlaceWithAnalysis(placeId);
    result.fold((error) => null, (analysisData) {
      // تحديث إحصائيات المكان لو لزم الأمر
    });
  }
}
