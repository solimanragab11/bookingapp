import 'package:equatable/equatable.dart';
import 'package:hanzbthalk/core/models/user_model.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Waiting for Firebase to send the SMS.
class LoginSendOTPLoading extends LoginState {
  const LoginSendOTPLoading();
}

/// SMS has been sent; stores the verificationId for the next step.
class LoginCodeSent extends LoginState {
  final String verificationId;

  const LoginCodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

/// Countdown active — user must wait before requesting a new code.
class LoginResendCountdown extends LoginState {
  final int seconds;

  const LoginResendCountdown(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

/// Countdown finished — user may request a new code.
class LoginResendEnabled extends LoginState {
  const LoginResendEnabled();
}

/// Waiting for Firebase to verify the OTP the user entered.
class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserModel user;

  const LoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class LoginError extends LoginState {
  /// A localization key (e.g. 'otpError', 'userNotFound').
  final String messageKey;

  const LoginError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}
