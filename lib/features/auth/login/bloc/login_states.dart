import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

// حالات إرسال كود الـ OTP
class LoginSendOTPLoading extends LoginState {}

class LoginCodeSent extends LoginState {
  final String verificationId;
  LoginCodeSent(this.verificationId);
}

// حالات التحقق من الكود (Verify)
class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserModel user;
  LoginSuccess(this.user);
}

// حالة الفشل (سواء الرقم مش موجود أو الكود غلط)
class LoginError extends LoginState {
  final String message; // بنخزن هنا الـ Key بتاع الـ Localization
  LoginError(this.message);
}
