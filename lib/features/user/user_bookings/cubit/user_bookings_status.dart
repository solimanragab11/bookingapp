import 'package:equatable/equatable.dart';

abstract class UserBookingsState extends Equatable {
  const UserBookingsState();

  @override
  List<Object?> get props => [];
}

// 1. الحالة الابتدائية
class UserBookingsInitial extends UserBookingsState {}

// 2. حالة التحميل (Loading)
class UserBookingsLoading extends UserBookingsState {}

// 3. حالة النجاح (Success) وفيها لستة الحجوزات وطلبات الاسترداد
class UserBookingsSuccess extends UserBookingsState {
  final List<Map<String, dynamic>> bookings;
  final List<Map<String, dynamic>> refundRequests;

  const UserBookingsSuccess(this.bookings, this.refundRequests);

  @override
  List<Object?> get props => [bookings, refundRequests];
}

// 4. حالة لو مفيش حجوزات خالص (Empty)
class UserBookingsEmpty extends UserBookingsState {}

// 5. حالة الخطأ (Failure)
class UserBookingsFailure extends UserBookingsState {
  final String errorMessage;

  const UserBookingsFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class UserBookingsCancelSuccess extends UserBookingsState {
  final double refundedAmount;
  const UserBookingsCancelSuccess(this.refundedAmount);

  @override
  List<Object?> get props => [refundedAmount];
}

class UserBookingsCancelFailure extends UserBookingsState {
  final String errorMessage;
  const UserBookingsCancelFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
