import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/auth_repo.dart';
import 'login_states.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo authRepo;

  LoginCubit(this.authRepo) : super(LoginInitial());

  // 1. طلب الـ OTP لتسجيل الدخول
  // features/auth/login/bloc/login_cubit.dart

  Future<void> sendLoginOTP(String phoneNumber) async {
    emit(LoginSendOTPLoading());

    // هنا التعديل: نستخدم الدالة اللي بتعمل تشيك الأول
    await authRepo.loginWithPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (verId) => emit(LoginCodeSent(verId)),
      onError: (errorKey) => emit(LoginError(errorKey)),
    );
  }

  // 2. التحقق من الكود والدخول
  Future<void> verifyLoginOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    emit(LoginLoading());
    try {
      // بننادي الـ verifyOTP من الـ Repo
      // لاحظ: في الـ Login إحنا مش محتاجين نبعت username أو role
      // لأن الـ Repo هيجيبهم من الـ Firestore أوتوماتيك بما إن اليوزر موجود
      final user = await authRepo.verifyOTP(
        verificationId: verificationId,
        smsCode: smsCode,
        username: '', // مش هيستخدموا لو اليوزر موجود فعلاً
        role: '', // مش هيستخدموا لو اليوزر موجود فعلاً
      );

      emit(LoginSuccess(user));
    } catch (e) {
      // لو الكود غلط مثلاً
      emit(
        LoginError(
          'otpError', // بنستخدم الـ Key بتاع الـ Localization عشان نجيب الرسالة المناسبة
        ),
      );
    }
  }

  void reset() => emit(LoginInitial());
}
