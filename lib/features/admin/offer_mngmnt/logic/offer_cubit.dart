import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/offer.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/admin/offer_mngmnt/logic/offer_states.dart';

class OwnerOfferCubit extends Cubit<OwnerOfferState> {
  final FirestoreOwnerService _service = FirestoreOwnerService(AuthService());
  OwnerOfferCubit() : super(OwnerOfferInitial());

  Future<void> submitOffer({
    required String placeId,
    required String subPlaceId,
    required String title,
    required String desc,
    required double discount,
    required DateTime expiry,
  }) async {
    emit(OwnerOfferLoading());
    try {
      final newOffer = Offer(
        id: "OFFER_${DateTime.now().millisecondsSinceEpoch}",
        title: title,
        description: desc,
        discountPercentage: discount,
        validUntil: expiry,
      );

      await _service.activateOffer(
        placeId: placeId,
        subPlaceId: subPlaceId,
        offer: newOffer,
      );
      emit(OwnerOfferSuccess());
    } catch (e) {
      emit(OwnerOfferFailure(e.toString()));
    }
  }
}
