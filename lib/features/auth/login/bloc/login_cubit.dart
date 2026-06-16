import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/features/auth/login/bloc/login_states.dart';
import 'package:hanzbthalk/features/auth/repo/auth_repo.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo _authRepo;

  Timer? _resendTimer;
  int _remainingSeconds = 60;

  String? _verificationId;
  String? get verificationId => _verificationId;

  LoginCubit(this._authRepo) : super(LoginInitial());

  // ---------------------------------------------------------------------------
  // Send OTP
  // ---------------------------------------------------------------------------

  Future<void> sendLoginOTP(String phoneNumber) async {
    if (isClosed) return;
    emit(LoginSendOTPLoading());

    await _authRepo.loginWithPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verId) {
        if (isClosed) return;
        _verificationId = verId;
        emit(LoginCodeSent(verId));
        _startResendTimer();
      },
      onError: (errorKey) {
        if (isClosed) return;
        emit(LoginError(errorKey));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Verify OTP
  // ---------------------------------------------------------------------------

  Future<void> verifyLoginOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    if (isClosed) return;
    emit(LoginLoading());
    try {
      final user = await _authRepo.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
        username: '',
        role: '',
      );
      _cancelTimer();
      if (isClosed) return;
      emit(LoginSuccess(user));
    } on DatabaseException catch (e) {
      debugPrint('[LoginCubit] verifyLoginOTP database error: ${e.message}');
      if (isClosed) return;
      emit(LoginError(e.message));
    } catch (e) {
      debugPrint('[LoginCubit] verifyLoginOTP error: $e');
      if (isClosed) return;
      emit(LoginError('otpError'));
    }
  }

  // ---------------------------------------------------------------------------
  // Timer
  // ---------------------------------------------------------------------------

  void _startResendTimer() {
    _cancelTimer();
    _remainingSeconds = 60;

    // Emit the initial countdown value immediately so the UI shows
    // "60" right away instead of jumping straight to 59 on first tick.
    if (isClosed) return;
    emit(LoginResendCountdown(_remainingSeconds));

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 0) {
        timer.cancel();
        emit(LoginResendEnabled());
        return;
      }

      _remainingSeconds--;
      emit(LoginResendCountdown(_remainingSeconds));
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
    if (isClosed) return;
    emit(LoginInitial());
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
