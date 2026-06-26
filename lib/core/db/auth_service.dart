import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import 'package:hanzbthalk/core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stores the resend token returned by Firebase so that subsequent
  /// OTP requests for the same phone number are not rate-limited.
  int? _resendToken;

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
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint(
            '[AuthService] verificationCompleted fired — '
            'attempting auto sign-in to complete the OTP verification.',
          );
          try {
            await _auth.signInWithCredential(credential);
            debugPrint('[AuthService] verificationCompleted — auto sign-in succeeded!');
          } catch (e) {
            debugPrint('[AuthService] verificationCompleted — auto sign-in failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(handleFirebaseAuthException(e));
        },
        codeSent: (String verId, int? resendToken) {
          _resendToken = resendToken;
          onCodeSent(verId); // بنبعت الـ verificationId للـ Cubit
        },
        codeAutoRetrievalTimeout: (String verId) {
          debugPrint(
            '[AuthService] codeAutoRetrievalTimeout fired for $verId — '
            'the SMS code can still be entered manually.',
          );
        },
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
    // If verificationCompleted auto-retrieved the code and already signed the user in,
    // we bypass signInWithCredential to avoid 'session-expired' or duplicate sign-in errors.
    final currentFirebaseUser = _auth.currentUser;
    if (currentFirebaseUser != null) {
      debugPrint('[AuthService] signInWithOtp — User is already signed in (auto-verified).');
      return MockUserCredential(user: currentFirebaseUser);
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      debugPrint(
        '[AuthService] signInWithOtp — attempting signIn with '
        'verificationId=${verificationId.substring(0, 8)}..., '
        'smsCode length=${smsCode.length}',
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService] signInWithOtp FirebaseAuthException — '
        'code: ${e.code}, message: ${e.message}',
      );
      // Fallback: If it failed with session-expired but currentUser is now non-null,
      // treat it as successful auto-verification.
      final fallbackUser = _auth.currentUser;
      if (fallbackUser != null) {
        debugPrint('[AuthService] signInWithOtp — error occurred but currentUser is not null, fallback to success.');
        return MockUserCredential(user: fallbackUser);
      }
      throw DatabaseException(handleFirebaseAuthException(e));
    } catch (e) {
      debugPrint('[AuthService] signInWithOtp unexpected error: $e');
      final fallbackUser = _auth.currentUser;
      if (fallbackUser != null) {
        return MockUserCredential(user: fallbackUser);
      }
      rethrow;
    }
  }

  // 4. جلب بيانات المستخدم الحالي من Firestore
  Future<UserModel?> getCurrentUser() async {
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
  }

  // الحصول على كائن المستخدم الحالي من Firebase Auth مباشرة
  User? get currentUser => _auth.currentUser;

  // إعادة تحميل بيانات المستخدم من السيرفر للتحقق من حالته
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<String?> getCurrentUserId() async {
    return _auth.currentUser?.uid;
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
        return 'phoneInvalid';
      case 'too-many-requests':
        return 'tooManyRequests';
      case 'session-expired':
        return 'session_expired';
      case 'invalid-verification-code':
        return 'invalid_otp';
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
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}

class MockUserCredential implements UserCredential {
  @override
  final User? user;
  @override
  final AuthCredential? credential;
  @override
  final AdditionalUserInfo? additionalUserInfo;

  MockUserCredential({
    this.user,
    this.credential,
    this.additionalUserInfo,
  });
}
