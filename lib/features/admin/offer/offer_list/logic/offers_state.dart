part of 'offers_cubit.dart';

@immutable
abstract class OffersState extends Equatable {
  const OffersState();

  @override
  List<Object> get props => [];
}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  // استخدام الموديل بتاعك هنا
  final List<OfferModel> offers;

  const OffersLoaded(this.offers);

  @override
  List<Object> get props => [offers];
}

class OffersError extends OffersState {
  final String message;

  const OffersError(this.message);

  @override
  List<Object> get props => [message];
}
