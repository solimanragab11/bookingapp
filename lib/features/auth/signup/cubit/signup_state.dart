import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {
  const SignUpInitial();
}

/// Waiting for Firebase to send the SMS or to verify the code.
class SignUpLoading extends SignUpState {
  const SignUpLoading();
}

/// SMS sent successfully — OTP sheet should be shown.
class SignUpCodeSent extends SignUpState {
  final String verificationId;

  const SignUpCodeSent(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
}

/// Countdown active — user must wait before requesting a new code.
class SignUpResendCountdown extends SignUpState {
  final int seconds;

  const SignUpResendCountdown(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

/// Countdown finished — user may request a new code.
class SignUpResendEnabled extends SignUpState {
  const SignUpResendEnabled();
}

class SignUpSuccess extends SignUpState {
  final String username;

  const SignUpSuccess(this.username);

  @override
  List<Object?> get props => [username];
}

class SignUpError extends SignUpState {
  /// A localization key (e.g. 'phoneNumberAlreadyExists', 'otpError').
  final String messageKey;

  const SignUpError(this.messageKey);

  @override
  List<Object?> get props => [messageKey];
}
