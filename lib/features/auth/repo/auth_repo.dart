import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

// ده الـ Interface اللي الـ Cubit بيفهمه
abstract class AuthRepo {
  AuthRepo(AuthService authService);

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verId) onCodeSent,
    required Function(String error) onError,
  });

  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String username,
    required String role,
  });
  Future<void> loginWithPhoneNumber({
    required String phoneNumber,
    required Function(String verId) onCodeSent,
    required Function(String error) onError,
  });
}

// أي ميثود تانية محتاجها...
