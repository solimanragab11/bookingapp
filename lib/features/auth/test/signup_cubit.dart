import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'signup_state.dart';

/// ---------------------------------------------------------------------------
/// SignupCubit — Clean Architecture BLoC layer for phone auth flow.
///
/// Folder:  lib/features/auth/signup/cubit/
/// ---------------------------------------------------------------------------
class SignupCubitTest extends Cubit<SignupState> {
  SignupCubitTest({FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? FirebaseAuth.instance,
      super(const SignupInitial());

  final FirebaseAuth _auth;

  // ── Stored verification id for resend / verify steps ──
  String? _verificationId;
  int? _resendToken;

  // ─────────────────────────────────────────────────────
  //  Terms checkbox toggle
  // ─────────────────────────────────────────────────────
  void toggleTerms({required bool accepted}) {
    if (state is SignupInitial) {
      emit(SignupInitial(termsAccepted: accepted));
    }
  }

  // ─────────────────────────────────────────────────────
  //  Validate Egyptian phone number
  // ─────────────────────────────────────────────────────
  /// Egypt mobile numbers: 01[0125]XXXXXXXX  (11 digits local)
  /// We normalise to E.164: +201XXXXXXXXX
  String? validateEgyptianPhone(String raw) {
    final cleaned = raw.trim().replaceAll(RegExp(r'\s|-'), '');
    final localPattern = RegExp(r'^01[0125]\d{8}$');
    final e164Pattern = RegExp(r'^\+201[0125]\d{8}$');

    if (localPattern.hasMatch(cleaned)) return '+2$cleaned';
    if (e164Pattern.hasMatch(cleaned)) return cleaned;
    return null; // invalid
  }

  // ─────────────────────────────────────────────────────
  //  Send OTP
  // ─────────────────────────────────────────────────────
  Future<void> sendOtp(String rawPhone) async {
    final bool termsAccepted =
        state is SignupInitial && (state as SignupInitial).termsAccepted;

    if (!termsAccepted) {
      emit(
        const SignupError(
          message: 'Please accept the Terms & Privacy Policy to continue.',
          type: SignupErrorType.phoneValidation,
        ),
      );
      return;
    }

    final e164 = validateEgyptianPhone(rawPhone);
    if (e164 == null) {
      emit(
        const SignupError(
          message: 'Enter a valid Egyptian mobile number (e.g. 01012345678).',
          type: SignupErrorType.phoneValidation,
        ),
      );
      return;
    }

    emit(const SignupSendingOtp());

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: e164,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),

        // ── Auto-retrieval (Android SMS listener) ──
        verificationCompleted: (PhoneAuthCredential credential) async {
          emit(const SignupVerifyingOtp());
          await _signInWithCredential(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          emit(
            SignupError(
              message: _mapFirebaseError(e),
              type: SignupErrorType.firebaseSend,
            ),
          );
        },

        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          emit(
            SignupOtpSent(verificationId: verificationId, phoneNumber: e164),
          );
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          emit(SignupOtpTimeout(verificationId: verificationId));
        },
      );
    } catch (e) {
      emit(SignupError(message: e.toString(), type: SignupErrorType.unknown));
    }
  }

  // ─────────────────────────────────────────────────────
  //  Verify OTP entered by user
  // ─────────────────────────────────────────────────────
  Future<void> verifyOtp(String otp) async {
    final currentVerificationId = _verificationId;
    if (currentVerificationId == null) {
      emit(
        const SignupError(
          message: 'Session expired. Please resend the code.',
          type: SignupErrorType.otpExpired,
        ),
      );
      return;
    }

    if (otp.trim().length != 6 || int.tryParse(otp.trim()) == null) {
      emit(
        const SignupError(
          message: 'Enter the 6-digit code sent to your phone.',
          type: SignupErrorType.otpInvalid,
        ),
      );
      return;
    }

    emit(const SignupVerifyingOtp());

    final credential = PhoneAuthProvider.credential(
      verificationId: currentVerificationId,
      smsCode: otp.trim(),
    );

    await _signInWithCredential(credential);
  }

  // ─────────────────────────────────────────────────────
  //  Internal sign-in helper
  // ─────────────────────────────────────────────────────
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final result = await _auth.signInWithCredential(credential);
      emit(SignupSuccess(uid: result.user!.uid));
    } on FirebaseAuthException catch (e) {
      emit(
        SignupError(
          message: _mapFirebaseError(e),
          type: e.code == 'invalid-verification-code'
              ? SignupErrorType.otpInvalid
              : SignupErrorType.unknown,
        ),
      );
    } catch (e) {
      emit(SignupError(message: e.toString(), type: SignupErrorType.unknown));
    }
  }

  // ─────────────────────────────────────────────────────
  //  Resend OTP (back to phone stage)
  // ─────────────────────────────────────────────────────
  void resendOtp(String rawPhone) {
    emit(const SignupInitial(termsAccepted: true));
    sendOtp(rawPhone);
  }

  // ─────────────────────────────────────────────────────
  //  Reset to initial
  // ─────────────────────────────────────────────────────
  void reset() => emit(const SignupInitial());

  // ─────────────────────────────────────────────────────
  //  Firebase error mapper
  // ─────────────────────────────────────────────────────
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number format is invalid.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'The OTP you entered is incorrect.';
      case 'session-expired':
        return 'The OTP has expired. Please resend.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
