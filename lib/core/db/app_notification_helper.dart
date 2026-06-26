import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/db/push_notification_service.dart';

class AppNotificationHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sends a notification to all administrators.
  static Future<void> notifyAdmins({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint("🔔 notifyAdmins: Sending admin notification document...");
      
      // 1. Fetch all admins from roles
      final rolesSnapshot = await _firestore
          .collection('roles')
          .where('role', isEqualTo: 'admin')
          .get();

      final List<String> adminIds = rolesSnapshot.docs.map((doc) => doc.id).toList();
      if (adminIds.isEmpty) {
        debugPrint("🔔 notifyAdmins: No admin users found in roles.");
        return;
      }

      // 2. Fetch admin FCM tokens
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: adminIds)
          .get();

      List<String> adminTokens = [];
      for (var doc in usersSnapshot.docs) {
        final token = doc.data()['fcmToken'] as String?;
        if (token != null && token.trim().isNotEmpty) {
          adminTokens.add(token.trim());
        }
      }

      // 3. Write a notification record for each admin (or a general admin notification doc)
      final batch = _firestore.batch();
      for (var adminId in adminIds) {
        final notifRef = _firestore.collection('notifications').doc();
        batch.set(notifRef, {
          'id': notifRef.id,
          'userId': adminId,
          'title': title,
          'body': body,
          'tokens': adminTokens,
          'targetRole': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending',
          if (data != null) 'data': data,
        });
      }
      await batch.commit();
      debugPrint("🔔 notifyAdmins: Admin notifications added to Firestore successfully.");
    } catch (e) {
      debugPrint("❌ notifyAdmins Error: $e");
    }
  }

  /// Sends a notification to the owner of a place.
  static Future<void> notifyOwner({
    required String placeId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      debugPrint("🔔 notifyOwner: Fetching ownerId for placeId: $placeId");
      
      final placeDoc = await _firestore.collection('places').doc(placeId).get();
      if (!placeDoc.exists) {
        debugPrint("🔔 notifyOwner: Place not found.");
        return;
      }

      final String ownerId = placeDoc.data()?['ownerId'] ?? '';
      if (ownerId.isEmpty) {
        debugPrint("🔔 notifyOwner: Place ownerId is empty.");
        return;
      }

      // Fetch owner token
      final ownerUserDoc = await _firestore.collection('users').doc(ownerId).get();
      List<String> tokens = [];
      if (ownerUserDoc.exists) {
        final token = ownerUserDoc.data()?['fcmToken'] as String?;
        if (token != null && token.trim().isNotEmpty) {
          tokens.add(token.trim());
        }
      }

      final notifRef = _firestore.collection('notifications').doc();
      await notifRef.set({
        'id': notifRef.id,
        'userId': ownerId,
        'title': title,
        'body': body,
        'tokens': tokens,
        'targetRole': 'owner',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        if (data != null) 'data': data,
      });
      debugPrint("🔔 notifyOwner: Owner notification added to Firestore successfully.");
    } catch (e) {
      debugPrint("❌ notifyOwner Error: $e");
    }
  }

  /// Schedules local reminders on the user's device for all upcoming bookings.
  static Future<void> scheduleRemindersForUser(List<Map<String, dynamic>> bookings, String currentUserId) async {
    try {
      final pushService = getIt<PushNotificationService>();
      await pushService.cancelAllReminders();

      for (var booking in bookings) {
        // Skip bookings that aren't active or belong to other users
        final status = (booking['status'] as String? ?? 'active').toLowerCase();
        if (status != 'active' && status != 'pending_no_show') continue;
        
        final String bookingUserId = booking['userId'] ?? '';
        if (bookingUserId != currentUserId) continue;

        final start = getBookingStartTime(booking);
        if (start == null) continue;

        // ID must be an integer for local notification ID
        final String bookingId = booking['id'] ?? '';
        final int notificationId = bookingId.hashCode;

        // Extract subPlace name or place name if available
        final placeInfo = booking['placeInfo'] as Map<String, dynamic>?;
        final placeName = placeInfo?['name'] ?? 'الملعب';
        
        // 1. تذكير قبل الحجز بساعة واحدة
        await pushService.scheduleUpcomingBookingReminder(
          id: notificationId,
          title: "تذكير بحجزك القريب ⚽",
          body: "حجزك في $placeName سيبدأ خلال ساعة واحدة. لا تتأخر!",
          scheduledDate: start,
          leadTime: const Duration(hours: 1),
          payload: bookingId,
        );

        // 2. تذكير قبل الحجز بـ 10 دقائق لتأكيد الدفع والـ QR
        await pushService.scheduleUpcomingBookingReminder(
          id: notificationId + 1,
          title: "موعد حجزك يقترب! 🎟️",
          body: "حجزك في $placeName سيبدأ بعد 10 دقائق. تفضل لتأكيد الدفع ومسح كود الـ QR!",
          scheduledDate: start,
          leadTime: const Duration(minutes: 10),
          payload: bookingId,
        );
      }
    } catch (e) {
      debugPrint("❌ scheduleRemindersForUser Error: $e");
    }
  }

  // Parse start time helper
  static DateTime? getBookingStartTime(Map<String, dynamic> booking) {
    try {
      final String fullDay = booking['timeSlots']?.keys?.first ?? "";
      final List<dynamic> slots = booking['timeSlots']?.values?.first ?? [];
      if (fullDay.isEmpty || slots.isEmpty) return null;

      final datePart = fullDay.contains(' ') ? fullDay.split(' ').last : "";
      if (datePart.isEmpty) return null;

      int year = DateTime.now().year;
      if (booking['createdAt'] != null) {
        final dynamic createdAtData = booking['createdAt'];
        if (createdAtData is DateTime) {
          year = createdAtData.year;
        } else if (createdAtData is Timestamp) {
          year = createdAtData.toDate().year;
        }
      }

      final String rawTimeRange = slots.first.toString();
      final String timePart = rawTimeRange.contains('-')
          ? rawTimeRange.split('-').first.trim()
          : rawTimeRange.trim();

      final dateComps = datePart.split('/');
      final timeComps = timePart.split(':');
      if (dateComps.length < 2 || timeComps.isEmpty) return null;

      final int day = int.parse(dateComps[0]);
      final int month = int.parse(dateComps[1]);
      if (dateComps.length >= 3) {
        year = int.parse(dateComps[2]);
      }

      int hour = int.parse(timeComps[0]);
      final int minute = timeComps.length > 1
          ? int.parse(timeComps[1].trim())
          : 0;

      int dayOffset = 0;
      if (hour >= 24) {
        dayOffset = hour ~/ 24;
        hour = hour % 24;
      }

      final parsed = DateTime(year, month, day, hour, minute);
      if (dayOffset > 0) {
        return parsed.add(Duration(days: dayOffset));
      }
      return parsed;
    } catch (e) {
      return null;
    }
  }
}
