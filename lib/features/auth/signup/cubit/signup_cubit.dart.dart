import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/statues/signup_state.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/auth_repo.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepo authRepo;
  String? _verificationId;

  SignUpCubit(this.authRepo) : super(SignUpInitial());

  // إرسال الـ OTP
  Future<void> sendOTP(String phoneNumber) async {
    emit(SignUpLoading());
    await authRepo.sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: (verId) {
        _verificationId = verId;
        emit(CodeSentState());
      },
      onError: (error) => emit(SignUpError(error)),
    );
  }

  // التأكيد وإنشاء الحساب ببيانات حقيقية
  Future<void> verifyOTP({
    required String smsCode,
    required String username,
  }) async {
    emit(SignUpLoading());
    try {
      await authRepo.verifyOTP(
        verificationId: _verificationId!,
        smsCode: smsCode,
        username: username,
        role: 'user',
      );
      emit(SignUpSuccess(username));
    } catch (e) {
      emit(SignUpError(e.toString()));
    }
  }
}
