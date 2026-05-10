import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_wrapper_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  UserModel? currentUser;

  AuthCubit(this._authService) : super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      if (!_authService.isUserLoggedIn()) {
        emit(const AuthUnauthenticated());
        return;
      }

      currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        // Firebase session exists but Firestore doc is missing — sign out cleanly.
        await _authService.signOut();
        emit(const AuthUnauthenticated());
        return;
      }

      final role = currentUser!.userRole;
      if (role != 'owner' && role != 'user' && role != 'admin') {
        // Unknown role — treat as unauthenticated to avoid routing into a broken screen.
        await _authService.signOut();
        currentUser = null;
        emit(const AuthUnauthenticated());
        return;
      }

      emit(AuthSuccess(user: currentUser!, role: role));
    } catch (e) {
      debugPrint('[AuthCubit] checkAuthStatus error: $e');
      emit(const AuthFailure('authError'));
    }
  }

  Future<void> refreshUserData() async {
    try {
      final updated = await _authService.getCurrentUser();
      if (updated != null) {
        currentUser = updated;
        emit(AuthSuccess(user: currentUser!, role: currentUser!.userRole));
      }
    } catch (e) {
      debugPrint('[AuthCubit] refreshUserData error: $e');
      // Silently keep existing state — a background refresh failure is non-fatal.
    }
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('[AuthCubit] logout error: $e');
    } finally {
      currentUser = null;
      emit(const AuthUnauthenticated());
    }
  }
}
