import 'package:flutter/foundation.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/auth_repo.dart';

class FirebaseAuthRepoImpl implements AuthRepo {
  final AuthService _authService;

  FirebaseAuthRepoImpl(this._authService);

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Strips leading zeros and prepends the Egyptian country code (+20).
  String _formatEgyptianNumber(String raw) {
    final clean = raw.trim().replaceAll(' ', '');
    final withoutLeadingZero = clean.startsWith('0')
        ? clean.substring(1)
        : clean;
    return '+20$withoutLeadingZero';
  }

  // ---------------------------------------------------------------------------
  // Sign-up OTP
  // ---------------------------------------------------------------------------

  @override
  Future<void> sendOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorKey) onError,
  }) async {
    final formatted = _formatEgyptianNumber(phoneNumber);
    try {
      final exists = await _authService.isPhoneNumberExists(formatted);
      if (exists) {
        onError('phoneNumberAlreadyExists');
        return;
      }
      await _authService.sendOTP(
        phoneNumber: formatted,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      debugPrint('[FirebaseAuthRepoImpl] sendOTP error: $e');
      onError('otpSendError');
    }
  }

  // ---------------------------------------------------------------------------
  // Login OTP
  // ---------------------------------------------------------------------------

  @override
  Future<void> loginWithPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorKey) onError,
  }) async {
    final formatted = _formatEgyptianNumber(phoneNumber);
    try {
      final exists = await _authService.isPhoneNumberExists(formatted);
      if (!exists) {
        onError('userNotFound');
        return;
      }
      await _authService.sendOTP(
        phoneNumber: formatted,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      debugPrint('[FirebaseAuthRepoImpl] loginWithPhoneNumber error: $e');
      onError('otpSendError');
    }
  }

  // ---------------------------------------------------------------------------
  // Verify OTP (shared between login and sign-up)
  // ---------------------------------------------------------------------------

  @override
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String username,
    required String role,
  }) async {
    final credential = await _authService.signInWithOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('verifyOTP: Firebase user is null after sign-in');
    }

    final userExists = await _authService.checkIfUserExists(firebaseUser.uid);

    if (userExists) {
      final existing = await _authService.getCurrentUser();
      if (existing != null) return existing;
      throw Exception(
        'verifyOTP: user document missing despite checkIfUserExists returning true',
      );
    }

    // Brand-new account — create and persist the Firestore document.
    final newUser = UserModel(
      id: firebaseUser.uid,
      username: username,
      phoneNumber: firebaseUser.phoneNumber ?? '',
      userRole: role,
      favoraitsPlaces: const [],
      ownedPlaces: const [],
      bookedPlaces: const [],
      offers: const [],
      history: const [],
      points: 0,
    );

    await _authService.addUser(newUser);
    return newUser;
  }
}
