// lib/features/user/booking/presentation/cubit/check_in_state.dart

abstract class CheckInState {}

class CheckInInitial extends CheckInState {}

class CheckInLoading extends CheckInState {}

// 🟢 نجاح: اليوزر عمل تشيك إن والحجز اتأكد بنجاح
class CheckInSuccess extends CheckInState {
  final String message;
  CheckInSuccess(this.message);
}

// 🔴 فشل: مثلاً الكود غلط، أو معندوش حجز في الميعاد ده
class CheckInFailure extends CheckInState {
  final String errorMessage;
  CheckInFailure(this.errorMessage);
}
