import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/errors/exceptions.dart';
import '../../domain/repositories/owner_onboarding_repository.dart';

class OwnerOnboardingRepositoryImpl implements OwnerOnboardingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- دالات ترقية رتبة المستخدم مباشرة عبر Firestore ---

  @override
  Future<void> upgradeToOwnerA({required bool acceptedAgreement}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw const UserNotAuthenticatedException("user_not_authenticated");
    }

    final uid = currentUser.uid;

    try {
      final WriteBatch batch = _firestore.batch();

      // // 1. تحديث مجموعة الـ roles (مصدر الحقيقة للرتب)
      // final DocumentReference roleDocRef = _firestore
      //     .collection('roles')
      //     .doc(uid);
      // batch.set(roleDocRef, {
      //   'role': 'owner_a',
      //   'updatedAt': FieldValue.serverTimestamp(),
      // }, SetOptions(merge: true));

      // 2. تحديث مجموعة الـ users (رتبة الكاش)
      final DocumentReference userDocRef = _firestore
          .collection('users')
          .doc(uid);
      batch.update(userDocRef, {'userRole': 'owner'});

      // // 3. كتابة سجل تدقيق في audit_logs
      // final DocumentReference auditLogDocRef = _firestore
      //     .collection('audit_logs')
      //     .doc();
      // batch.set(auditLogDocRef, {
      //   'userId': uid,
      //   'action': 'OWNER_UPGRADED',
      //   'previousRole': 'owner_b',
      //   'newRole': 'owner_a',
      //   'timestamp': FieldValue.serverTimestamp(),
      //   'details': 'User accepted agreement and upgraded directly to owner_a',
      // });

      // // 4. إرسال حدث الترقية في مجموعة events
      // final DocumentReference eventDocRef = _firestore
      //     .collection('events')
      //     .doc();
      // batch.set(eventDocRef, {
      //   'eventType': 'OWNER_UPGRADED',
      //   'userId': uid,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });

      // تنفيذ العمليات كدفعة واحدة لضمان الاتساق الذري
      await batch.commit();
      debugPrint("تم ترقية المالك $uid بنجاح إلى owner_a في Firestore ✅");
    } catch (e) {
      debugPrint("خطأ أثناء ترقية المالك إلى owner_a: $e ❌");
      rethrow;
    }
  }
}
