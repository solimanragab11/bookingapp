import 'package:hanzbthalk/core/models/user_model.dart';

/// The contract that every auth implementation must fulfil.
/// Cubits depend only on this — never on Firebase directly.
abstract class AuthRepo {
  /// Sends a one-time password for a **new** registration.
  /// Validates that the phone number does NOT already exist.
  Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorKey) onError,
  });

  /// Sends a one-time password for an **existing** user login.
  /// Validates that the phone number DOES already exist.
  Future<void> loginWithPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorKey) onError,
  });

  /// Verifies the OTP code.
  /// [username] and [role] are only used when creating a brand-new account.
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String username,
    required String role,
  });

  /// Signs up a user by verifying their phone OTP and linking a 6-digit PIN.
  Future<UserModel> signUpWithPhoneAndPin({
    required String verificationId,
    required String smsCode,
    required String username,
    required String role,
    required String pin,
    required String phoneNumber,
  });

  /// Signs in a user directly using their phone number and 6-digit PIN.
  Future<UserModel> signInWithPhoneAndPin({
    required String phoneNumber,
    required String pin,
  });

  /// Sends an OTP for resetting a PIN after verifying the phone number exists.
  Future<void> sendResetPinOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorKey) onError,
  });

  /// Resets the user's PIN after validating the OTP verification code.
  Future<void> resetPin({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPin,
  });
}
