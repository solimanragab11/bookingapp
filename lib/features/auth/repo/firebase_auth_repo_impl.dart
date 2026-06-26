import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/features/auth/repo/auth_repo.dart';

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
      throw const UserNotAuthenticatedException(
        'verifyOTP: Firebase user is null after sign-in',
      );
    }

    // Single query to check existence and retrieve the document safely.
    // If this throws an exception due to network failure, the method will fail and
    // NOT execute the addUser() below, saving user data from overwrite/corruption!
    final existing = await _authService.getUserById(firebaseUser.uid);
    if (existing != null) {
      return existing;
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
      fcmToken: await FirebaseMessaging.instance.getToken() ?? '  ',
    );

    await _authService.addUser(newUser);
    return newUser;
  }

  @override
  Future<UserModel> signUpWithPhoneAndPin({
    required String verificationId,
    required String smsCode,
    required String username,
    required String role,
    required String pin,
    required String phoneNumber,
  }) async {
    final formattedPhone = _formatEgyptianNumber(phoneNumber);

    // 1. Verify OTP first (signs the user in via Phone Auth)
    final credential = await _authService.signInWithOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw const UserNotAuthenticatedException(
        'signUpWithPhoneAndPin: User is null after OTP verification',
      );
    }

    // 2. Link Email Credential (fake email)
    final fakeEmail = '$formattedPhone@hanzbthalk.app';
    final emailCredential = EmailAuthProvider.credential(
      email: fakeEmail,
      password: pin,
    );

    try {
      await firebaseUser.linkWithCredential(emailCredential);
    } on FirebaseAuthException catch (e) {
      // If the email provider is already linked or email exists, ignore it, otherwise throw
      if (e.code != 'provider-already-linked' &&
          e.code != 'email-already-in-use') {
        throw DatabaseException(_mapAuthError(e.code));
      }
    }

    // 3. Create and persist user in Firestore
    final newUser = UserModel(
      id: firebaseUser.uid,
      username: username,
      phoneNumber: formattedPhone,
      userRole: role,
      favoraitsPlaces: const [],
      ownedPlaces: const [],
      bookedPlaces: const [],
      offers: const [],
      history: const [],
      points: 0,
      fcmToken: await FirebaseMessaging.instance.getToken() ?? '  ',
    );

    await _authService.addUser(newUser);
    return newUser;
  }

  @override
  Future<UserModel> signInWithPhoneAndPin({
    required String phoneNumber,
    required String pin,
  }) async {
    final formattedPhone = _formatEgyptianNumber(phoneNumber);
    final fakeEmail = '$formattedPhone@hanzbthalk.app';

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: fakeEmail,
        password: pin,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const UserNotAuthenticatedException(
          'signInWithPhoneAndPin: User is null after sign-in',
        );
      }

      final existing = await _authService.getUserById(firebaseUser.uid);
      if (existing == null) {
        throw const UserNotAuthenticatedException(
          'signInWithPhoneAndPin: User document not found in database',
        );
      }

      return existing;
    } on FirebaseAuthException catch (e) {
      throw DatabaseException(_mapAuthError(e.code));
    }
  }

  @override
  Future<void> sendResetPinOTP({
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
      debugPrint('[FirebaseAuthRepoImpl] sendResetPinOTP error: $e');
      onError('otpSendError');
    }
  }

  @override
  Future<void> resetPin({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPin,
  }) async {
    try {
      // 1. Verify OTP first (signs user in)
      final credential = await _authService.signInWithOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const UserNotAuthenticatedException(
          'resetPin: User is null after OTP verification',
        );
      }

      // 2. Update password (which represents the PIN)
      // We try updatePassword first. If it fails (common when signed in via Phone provider
      // where the user email is null or not re-authenticated), we unlink the old password provider
      // and re-link the email credential with the new PIN.
      final formattedPhone = _formatEgyptianNumber(phoneNumber);
      final fakeEmail = '$formattedPhone@hanzbthalk.app';
      final emailCredential = EmailAuthProvider.credential(
        email: fakeEmail,
        password: newPin,
      );

      try {
        debugPrint('[FirebaseAuthRepoImpl] resetPin — attempting updatePassword first.');
        await firebaseUser.updatePassword(newPin);
        debugPrint('[FirebaseAuthRepoImpl] resetPin — updatePassword succeeded.');
      } catch (e) {
        debugPrint('[FirebaseAuthRepoImpl] resetPin — updatePassword failed: $e. Falling back to unlink & link.');
        
        try {
          await firebaseUser.unlink('password');
          debugPrint('[FirebaseAuthRepoImpl] resetPin — unlinked old password provider.');
        } catch (unlinkError) {
          debugPrint('[FirebaseAuthRepoImpl] resetPin — unlink failed (or already unlinked): $unlinkError');
        }

        await firebaseUser.linkWithCredential(emailCredential);
        debugPrint('[FirebaseAuthRepoImpl] resetPin — linked new email/password provider with new PIN.');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[FirebaseAuthRepoImpl] resetPin FirebaseAuthException — code: ${e.code}, message: ${e.message}');
      throw DatabaseException(_mapAuthError(e.code));
    } catch (e) {
      debugPrint('[FirebaseAuthRepoImpl] resetPin unexpected error: $e');
      throw DatabaseException(e.toString());
    }
  }

  /// Helper to map Firebase Auth error codes to user-friendly keys.
  String _mapAuthError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'incorrectPin';
      case 'user-not-found':
        return 'userNotFound';
      case 'too-many-requests':
        return 'tooManyRequests';
      case 'invalid-phone-number':
        return 'phoneInvalid';
      case 'invalid-verification-code':
        return 'invalid_otp';
      case 'session-expired':
        return 'session_expired';
      default:
        return code; // Return the raw error code for better debugging/transparency
    }
  }
}
