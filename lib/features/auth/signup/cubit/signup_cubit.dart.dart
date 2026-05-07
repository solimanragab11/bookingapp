import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/auth_repo.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepo _authRepo;

  Timer? _resendTimer;
  int _remainingSeconds = 60;

  // Stored here so verifyOTP can access it without relying on the UI
  // passing it back — eliminates the force-unwrap crash risk.
  String? _verificationId;

  SignUpCubit(this._authRepo) : super( SignUpInitial());

  // ---------------------------------------------------------------------------
  // Send OTP (registration flow)
  // ---------------------------------------------------------------------------

  Future<void> sendOTP(String phoneNumber) async {
    emit( SignUpLoading());

    await _authRepo.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verId) {
        _verificationId = verId;
        emit(SignUpCodeSent(verId));
        _startResendTimer();
      },
      onError: (errorKey) => emit(SignUpError(errorKey)),
    );
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  Future<void> verifyOTP({
    required String smsCode,
    required String username,
  }) async {
    if (_verificationId == null) {
      // Guard: should never happen in normal flow, but let's be explicit.
      emit( SignUpError('otpSessionExpired'));
      return;
    }

    emit( SignUpLoading());
    try {
      await _authRepo.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
        username: username,
        role: 'user',
      );
      _cancelTimer();
      emit(SignUpSuccess(username));
    } catch (e) {
      debugPrint('[SignUpCubit] verifyOTP error: $e');
      emit( SignUpError('otpError'));
    }
  }

  // ---------------------------------------------------------------------------
  // Resend OTP
  // ---------------------------------------------------------------------------

  Future<void> resendOTP(String phoneNumber) async {
    _cancelTimer();
    await sendOTP(phoneNumber);
  }

  // ---------------------------------------------------------------------------
  // Timer
  // ---------------------------------------------------------------------------

  void _startResendTimer() {
    _cancelTimer();
    _remainingSeconds = 60;

    _resendTimer = Timer.periodic( Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds == 0) {
        timer.cancel();
        emit( SignUpResendEnabled());
      } else {
        _remainingSeconds--;
        emit(SignUpResendCountdown(_remainingSeconds));
      }
    });
  }

  void _cancelTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------

  void reset() {
    _cancelTimer();
    _verificationId = null;
    emit( SignUpInitial());
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
