import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_Wrapper_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  // الدالة اللي بتناديها في الـ main أو الـ initState
  void checkAuthStatus() async {
    emit(AuthLoading());
    try {
      if (_authService.isUserLoggedIn()) {
        UserModel? user = await _authService.getCurrentUser();
        if (user != null) {
          // هنا بنبعت الـ role عشان الـ Wrapper يوجه المستخدم صح
          emit(AuthSuccess(user: user, role: user.userRole));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void logout() async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }
}
