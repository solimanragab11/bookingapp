import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/offer_model.dart';

// تأكد من مسارات الملفات دي عندك
// import 'package:hanzbthalk/.../offer.dart';
// import 'package:hanzbthalk/.../admin_service.dart';

part 'offers_state.dart';

class OffersCubit extends Cubit<OffersState> {
  // بنعمل نسخة من السيرفيس عشان نكلمها
  final AdminService _adminService = AdminService();

  OffersCubit() : super(OffersInitial());

  /// جلب كل العروض من الفايربيز
  Future<void> fetchOffers() async {
    emit(OffersLoading());
    try {
      // بنستدعي الدالة اللي لسه ضايفينها في السيرفيس
      final offers = await _adminService.getAllOffers();

      // بنبعت الداتا للشاشة
      emit(OffersLoaded(offers));
    } catch (e) {
      emit(OffersError("فشل في تحميل العروض: ${e.toString()}"));
    }
  }

  /// دالة إضافية عشان لو حبيت تحذف عرض من الشاشة مباشرة (اختياري)
  Future<void> deleteOffer(String offerId) async {
    try {
      await _adminService.deleteOffer(offerId);
      // بعد ما يحذف بنعمل Refresh للعروض
      fetchOffers();
    } catch (e) {
      emit(OffersError("فشل في حذف العرض: ${e.toString()}"));
    }
  }

  // جوه كلاس OffersCubit

  String getNewOfferId() {
    return _adminService.getNewOfferId();
  }

  Future<void> saveOffer(OfferModel offer) async {
    try {
      await _adminService.saveOffer(offer);
    } catch (e) {
      throw DatabaseException("Failed to save offer: $e");
    }
  }

  Future<void> updateOffer(OfferModel offer) async {
    try {
      await _adminService.updateOffer(offer);
    } catch (e) {
      throw DatabaseException("Failed to update offer: $e");
    }
  }
}
