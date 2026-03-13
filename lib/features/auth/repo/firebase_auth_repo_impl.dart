// ignore_for_file: override_on_non_overriding_member

import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/auth_repo.dart';

class FirebaseAuthRepoImpl implements AuthRepo {
  final AuthService authService;

  FirebaseAuthRepoImpl(this.authService);

  @override
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verId) onCodeSent,
    required Function(String error) onError,
  }) async {
    // 1. تنظيف وتنسيق الرقم
    String cleanNumber = phoneNumber.trim();
    if (cleanNumber.startsWith('0')) cleanNumber = cleanNumber.substring(1);
    String finalNumber = '+20$cleanNumber';

    try {
      // 2. التشيك السحري: هل الرقم موجود قبل كدة؟
      bool exists = await authService.isPhoneNumberExists(finalNumber);

      if (exists) {
        onError('phoneNumberAlreadyExists');
        return; // بنخرج من الدالة ومش بننادي الـ sendOTP بتاع Firebase
      }

      // 3. لو مش موجود، كمل وابعت الـ OTP عادي
      await authService.sendOTP(
        phoneNumber: finalNumber,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      onError('phoneNumberAlreadyExists');
    }
  }

  @override
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String smsCode,
    required String username,
    required String role,
  }) async {
    // 1. تسجيل الدخول باستخدام الـ OTP من خلال الـ Service
    final userCredential = await authService.signInWithOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final user = userCredential.user;
    if (user == null) throw Exception("Authentication Failed");

    // 2. التأكد هل المستخدم موجود في Firestore فعلاً؟
    final userExists = await authService.checkIfUserExists(user.uid);

    if (userExists) {
      // إذا كان موجوداً، نجلب بياناته الحالية
      final existingUser = await authService.getCurrentUser();
      if (existingUser != null) return existingUser;
      throw Exception("Error retrieving user data");
    } else {
      // 3. إذا كان مستخدماً جديداً، نقوم بإنشائه وحفظه
      final newUser = UserModel(
        id: user.uid,
        username: username,
        phoneNumber: user.phoneNumber ?? '',
        userRole: role, // 'user' or 'owner' من الـ UI
        favoraitsPlaces: [],
        ownedPlaces: [],
        bookedPlaces: [],
        offers: [],
        history: [],
        points: 0,
      );

      await authService.addUser(newUser);
      return newUser;
    }
  }

  @override
  Future<UserModel?> checkAuthStatus() async {
    // بيستخدمها الـ AuthCubit عشان يحدد يفتح أنهي شاشة
    return await authService.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    // تسجيل خروج نظيف
    await authService.signOut();
  }

  @override
  Future<void> loginWithPhoneNumber({
    required String phoneNumber,
    required Function(String verId) onCodeSent,
    required Function(String error) onError,
  }) async {
    // 1. تنظيف الرقم
    String cleanNumber = phoneNumber.trim();
    if (cleanNumber.startsWith('0')) cleanNumber = cleanNumber.substring(1);
    String finalNumber = '+20$cleanNumber';

    try {
      // 2. التشيك: هل الرقم موجود؟
      bool exists = await authService.isPhoneNumberExists(finalNumber);
      if (!exists) {
        // لو مش موجود، بنقوله "يا عم السولي الرقم ده مش عندنا، روح سجل الأول"
        onError('userNotFound');
        return;
      }

      // 3. لو موجود، ابعت الـ OTP عشان يكمل الـ Login
      await authService.sendOTP(
        phoneNumber: finalNumber,
        onCodeSent: onCodeSent,
        onError: onError,
      );
    } catch (e) {
      onError('error');
    }
  }
}
