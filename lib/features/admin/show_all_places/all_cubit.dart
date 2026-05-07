import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/offer.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/admin/show_all_places/states.dart';

class AdminOfferCubit extends Cubit<AdminOfferState> {
  final FirestoreOwnerService _service = FirestoreOwnerService(AuthService());

  AdminOfferCubit() : super(AdminOfferInitial()); // الحالة الابتدائية الجديدة

  Future<void> getAllPlacesForAdmin() async {
    emit(AdminOfferLoading()); // حالة التحميل الموحدة
    try {
      final places = await _service.getAllPlaces();
      emit(AdminPlacesLoaded(places)); // الحالة الجديدة
    } catch (e) {
      emit(AdminOfferFailure(e.toString()));
    }
  }

  Future<void> activateAdminOffer({
    required String placeId,
    required String subPlaceId,
    required Offer offer,
  }) async {
    emit(AdminOfferLoading());
    try {
      await _service.activateOffer(
        placeId: placeId,
        subPlaceId: subPlaceId,
        offer: offer,
      );
      emit(AdminOfferActivatedSuccess()); // حالة النجاح الجديدة
    } catch (e) {
      emit(AdminOfferFailure(e.toString()));
    }
  }
}
