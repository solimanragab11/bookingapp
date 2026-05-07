import 'package:equatable/equatable.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class AdminOfferState extends Equatable {
  const AdminOfferState();

  @override
  List<Object?> get props => [];
}

// 1. الحالة الابتدائية
class AdminOfferInitial extends AdminOfferState {}

// 2. حالة التحميل (للكل)
class AdminOfferLoading extends AdminOfferState {}

// 3. حالة جلب الأماكن بنجاح
class AdminPlacesLoaded extends AdminOfferState {
  final List<PlaceModel> places; // تأكد إن الموديل اسمه PlaceModel

  const AdminPlacesLoaded(this.places);

  @override
  List<Object?> get props => [places];
}

// 4. حالة نجاح تفعيل العرض
class AdminOfferActivatedSuccess extends AdminOfferState {}

// 5. حالة الفشل
class AdminOfferFailure extends AdminOfferState {
  final String errorMessage;

  const AdminOfferFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
