import 'package:equatable/equatable.dart';

abstract class OwnerOfferState extends Equatable {
  const OwnerOfferState();

  @override
  List<Object?> get props => [];
}

// 1. الحالة الابتدائية
class OwnerOfferInitial extends OwnerOfferState {}

// 2. حالة التحميل (لما المالك يدوس تفعيل)
class OwnerOfferLoading extends OwnerOfferState {}

// 3. حالة النجاح (لما العرض يتسجل في Firestore)
class OwnerOfferSuccess extends OwnerOfferState {}

// 4. حالة الفشل (لو حصل مشكلة في النت أو الداتابيز)
class OwnerOfferFailure extends OwnerOfferState {
  final String errorMessage;

  const OwnerOfferFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
