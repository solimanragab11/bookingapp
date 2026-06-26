import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_wrapper_states.dart';
import 'package:hanzbthalk/features/auth/repo/auth_repo.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final AuthRepo _authRepo;

  UserModel? currentUser;

  AuthCubit(this._authService, this._authRepo) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      if (!_authService.isUserLoggedIn()) {
        emit(const AuthUnauthenticated());
        return;
      }

      // 1. Validate Firebase Auth Session with a Reload
      try {
        await _authService.reloadUser();
      } on FirebaseAuthException catch (fe) {
        debugPrint('[AuthCubit] checkAuthStatus reload FirebaseAuthException: ${fe.code}');
        if (fe.code == 'user-not-found' ||
            fe.code == 'user-disabled' ||
            fe.code == 'invalid-credential') {
          // Session is invalid on server — log out cleanly.
          await _authService.signOut();
          currentUser = null;
          emit(const AuthUnauthenticated());
          return;
        } else {
          // Network or other transient error — do NOT sign out!
          emit(const AuthFailure('networkError'));
          return;
        }
      } catch (e) {
        debugPrint('[AuthCubit] checkAuthStatus reload generic error: $e');
        emit(const AuthFailure('networkError'));
        return;
      }

      // 2. Fetch User Document from Firestore
      try {
        currentUser = await _authService.getCurrentUser();
        if (currentUser == null) {
          // Firebase Auth session is active but user document is missing in Firestore.
          // Force sign out to recover cleanly.
          await _authService.signOut();
          emit(const AuthUnauthenticated());
          return;
        }
      } catch (fe) {
        // Firestore fetch failed (most likely network/timeout error)
        debugPrint('[AuthCubit] checkAuthStatus fetch error: $fe');
        emit(const AuthFailure('networkError'));
        return;
      }

      // 3. Validate Role
      final role = currentUser!.userRole;
      if (role != 'owner' &&
          role != 'owner_a' &&
          role != 'owner_b' &&
          role != 'employee' &&
          role != 'user' &&
          role != 'admin') {
        // Unknown role — treat as unauthenticated to avoid routing into a broken screen.
        await _authService.signOut();
        currentUser = null;
        emit(const AuthUnauthenticated());
        return;
      }

      emit(AuthSuccess(user: currentUser!, role: role));
    } catch (e) {
      debugPrint('[AuthCubit] checkAuthStatus fatal error: $e');
      emit(const AuthFailure('authError'));
    }
  }

  Future<void> refreshUserData() async {
    try {
      final updated = await _authService.getCurrentUser();
      if (updated != null) {
        currentUser = updated;
        emit(AuthSuccess(user: currentUser!, role: currentUser!.userRole));
      } else {
        // Firestore user document missing — sign out cleanly.
        await logout();
      }
    } catch (e) {
      debugPrint('[AuthCubit] refreshUserData error: $e');
      // Silently keep existing state — a background refresh failure is non-fatal.
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      // Reset the lazy singleton Cubit to clear previous owner's data
      if (getIt.isRegistered<ManageBookingPlaceCubit>()) {
        await getIt.resetLazySingleton<ManageBookingPlaceCubit>();
      }
    } catch (e) {
      debugPrint('[AuthCubit] logout error: $e');
    } finally {
      currentUser = null;
      emit(const AuthUnauthenticated());
    }
  }

  // ===========================================================================
  // PIN-Based Authentication Methods
  // ===========================================================================

  Future<void> sendSignUpOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorKey) onError,
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepo.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verId) {
          emit(AuthOtpSent(verId));
          onCodeSent(verId);
        },
        onError: (errKey) {
          emit(AuthFailure(errKey));
          onError(errKey);
        },
      );
    } catch (e) {
      debugPrint('[AuthCubit] sendSignUpOTP generic error: $e');
      emit(const AuthFailure('otpSendError'));
      onError('otpSendError');
    }
  }

  Future<void> signUpWithPhoneAndPin({
    required String verificationId,
    required String smsCode,
    required String username,
    required String role,
    required String pin,
    required String phoneNumber,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepo.signUpWithPhoneAndPin(
        verificationId: verificationId,
        smsCode: smsCode,
        username: username,
        role: role,
        pin: pin,
        phoneNumber: phoneNumber,
      );
      currentUser = user;
      emit(AuthSuccess(user: user, role: user.userRole));
    } on DatabaseException catch (e) {
      debugPrint('[AuthCubit] signUpWithPhoneAndPin database error: ${e.message}');
      emit(AuthFailure(e.message));
    } on UserNotAuthenticatedException catch (e) {
      debugPrint('[AuthCubit] signUpWithPhoneAndPin authentication error: ${e.message}');
      emit(AuthFailure(e.message));
    } catch (e) {
      debugPrint('[AuthCubit] signUpWithPhoneAndPin generic error: $e');
      emit(const AuthFailure('authError'));
    }
  }

  Future<void> loginWithPhoneAndPin({
    required String phoneNumber,
    required String pin,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepo.signInWithPhoneAndPin(
        phoneNumber: phoneNumber,
        pin: pin,
      );
      currentUser = user;
      emit(AuthSuccess(user: user, role: user.userRole));
    } on DatabaseException catch (e) {
      debugPrint('[AuthCubit] loginWithPhoneAndPin database error: ${e.message}');
      emit(AuthFailure(e.message));
    } on UserNotAuthenticatedException catch (e) {
      debugPrint('[AuthCubit] loginWithPhoneAndPin authentication error: ${e.message}');
      emit(AuthFailure(e.message));
    } catch (e) {
      debugPrint('[AuthCubit] loginWithPhoneAndPin generic error: $e');
      emit(const AuthFailure('authError'));
    }
  }

  Future<void> sendResetPinOTP({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorKey) onError,
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepo.sendResetPinOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verId) {
          emit(AuthOtpSent(verId));
          onCodeSent(verId);
        },
        onError: (errKey) {
          emit(AuthFailure(errKey));
          onError(errKey);
        },
      );
    } catch (e) {
      debugPrint('[AuthCubit] sendResetPinOTP generic error: $e');
      emit(const AuthFailure('otpSendError'));
      onError('otpSendError');
    }
  }

  Future<void> resetPin({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
    required String newPin,
  }) async {
    emit(const AuthLoading());
    try {
      await _authRepo.resetPin(
        verificationId: verificationId,
        smsCode: smsCode,
        phoneNumber: phoneNumber,
        newPin: newPin,
      );
      emit(const AuthResetPinSuccess());
    } on DatabaseException catch (e) {
      debugPrint('[AuthCubit] resetPin database error: ${e.message}');
      emit(AuthFailure(e.message));
    } on UserNotAuthenticatedException catch (e) {
      debugPrint('[AuthCubit] resetPin authentication error: ${e.message}');
      emit(AuthFailure(e.message));
    } catch (e) {
      debugPrint('[AuthCubit] resetPin generic error: $e');
      emit(const AuthFailure('authError'));
    }
  }
}
