import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. التحقق من حالة تسجيل الدخول
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // 2. إرسال كود الـ OTP للموبايل (تمت الإضافة)
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // في بعض أجهزة أندرويد يتم التحقق تلقائياً
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(handleFirebaseAuthException(e));
        },
        codeSent: (String verId, int? resendToken) {
          onCodeSent(verId); // بنبعت الـ verificationId للـ Cubit
        },
        codeAutoRetrievalTimeout: (String verId) {},
      );
    } catch (e) {
      onError('error');
    }
  }

  // 3. تسجيل الدخول باستخدام الكود المستلم (تمت الإضافة)
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // 4. جلب بيانات المستخدم الحالي من Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error in getCurrentUser: $e");
      return null;
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          UserModel user = UserModel.fromJson(
            doc.data() as Map<String, dynamic>,
          );
          return user.id;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error in getCurrentUser: $e");
      return null;
    }
  }

  // 5. فحص هل المستخدم موجود مسبقاً في Firestore (تمت الإضافة)
  Future<bool> checkIfUserExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  // 6. إضافة مستخدم جديد للـ Firestore
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  // 7. تحديث رتبة المستخدم
  Future<void> updateUserRole(String uid, String newRole) async {
    await _firestore.collection('users').doc(uid).update({'userRole': newRole});
  }

  // 8. تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  // 9. التعامل مع أخطاء الـ Firebase (معدل لاستخدام الـ Keys)
  String handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'invalidEmail';
      case 'too-many-requests':
        return 'tooManyRequests';
      case 'session-expired':
        return 'sessionExpired';
      case 'invalid-verification-code':
        return 'invalidCode';
      default:
        return e.toString();
    }
  }

  // جوه ملف auth_service.dart
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    final result = await _firestore
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return result.docs.isNotEmpty; // لو لقى أي Document يبقى الرقم موجود
  }
  // inside owner_service.dart

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint("Error in getCurrentUser: $e");
      return null;
    }
  }
}
