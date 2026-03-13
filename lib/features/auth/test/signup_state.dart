part of 'signup_cubit.dart';

/// Represents all possible states for the Sign-Up flow.
abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state — phone input stage visible.
class SignupInitial extends SignupState {
  final bool termsAccepted;
  const SignupInitial({this.termsAccepted = false});

  @override
  List<Object?> get props => [termsAccepted];
}

/// Firebase is sending the OTP to the phone number.
class SignupSendingOtp extends SignupState {
  const SignupSendingOtp();
}

/// OTP sent successfully — transition to OTP input stage.
class SignupOtpSent extends SignupState {
  final String verificationId;
  final String phoneNumber;

  const SignupOtpSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

/// User is verifying the entered OTP code.
class SignupVerifyingOtp extends SignupState {
  const SignupVerifyingOtp();
}

/// Authentication succeeded.
class SignupSuccess extends SignupState {
  final String uid;
  const SignupSuccess({required this.uid});

  @override
  List<Object?> get props => [uid];
}

/// An error occurred at any stage.
class SignupError extends SignupState {
  final String message;
  final SignupErrorType type;

  const SignupError({required this.message, required this.type});

  @override
  List<Object?> get props => [message, type];
}

/// OTP auto-retrieval timed out.
class SignupOtpTimeout extends SignupState {
  final String verificationId;
  const SignupOtpTimeout({required this.verificationId});

  @override
  List<Object?> get props => [verificationId];
}

enum SignupErrorType {
  phoneValidation,
  firebaseSend,
  otpInvalid,
  otpExpired,
  network,
  unknown,
}
