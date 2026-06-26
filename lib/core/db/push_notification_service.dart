import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/routes/routing.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 🛑 دي لازم تكون Top-level function (بره الكلاس خالص) عشان تشتغل والأبليكيشن مقفول
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("🔔 Background Message Received: ${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. طلب صلاحيات الـ FCM (مهم جداً للـ iOS والأندرويد 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('🔔 User granted FCM permission: ${settings.authorizationStatus}');

    // 2. طلب صلاحية الإشعارات المحلية للأندرويد 13+ (POST_NOTIFICATIONS)
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        debugPrint("🔔 Android local notifications permission status: $granted");
      }
    } catch (e) {
      debugPrint("⚠️ Failed to request Android local notification permission: $e");
    }

    // 3. إعداد الـ Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. إعداد الإشعارات المحلية (Local Notifications) والـ Callbacks لضغطات الإشعارات
    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInitSettings);
    
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          debugPrint("🔔 Local Notification tapped, payload: $payload");
          AppRouter.navigatorKey.currentState?.pushNamed(
            Routes.myBookings,
            arguments: payload,
          );
        }
      },
    );

    // 5. تهيئة التوقيت للمواعيد المجدولة (Timezones)
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      debugPrint("🔔 Timezones Initialized successfully to Africa/Cairo.");
    } catch (e) {
      debugPrint("⚠️ Failed to initialize timezones: $e");
    }

    // 6. التعامل مع فتح التطبيق من إشعار محلي وهو مقفول تماماً (Terminated)
    try {
      final NotificationAppLaunchDetails? launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          debugPrint("🔔 App launched from local notification tap with payload: $payload");
          Future.delayed(const Duration(milliseconds: 1500), () {
            AppRouter.navigatorKey.currentState?.pushNamed(
              Routes.myBookings,
              arguments: payload,
            );
          });
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error checking local notification app launch: $e");
    }

    // 7. الاستماع للإشعارات والأبليكيشن مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 Got a message whilst in the foreground!');
      debugPrint('🔔 Message data: ${message.data}');

      if (message.notification != null) {
        _showLocalNotification(message.notification!, message.data['bookingId']);
      }
    });

    // 8. الاستماع لضغطات إشعارات الـ FCM عندما يكون التطبيق في الخلفية (Background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("🔔 FCM Notification clicked! Data: ${message.data}");
      final bookingId = message.data['bookingId'];
      if (bookingId != null && bookingId.toString().isNotEmpty) {
        AppRouter.navigatorKey.currentState?.pushNamed(
          Routes.myBookings,
          arguments: bookingId.toString(),
        );
      }
    });

    // 9. التعامل مع تشغيل التطبيق من إشعار FCM والتطبيق مقفول تماماً (Terminated)
    try {
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint("🔔 App launched from FCM notification with data: ${initialMessage.data}");
        final bookingId = initialMessage.data['bookingId'];
        if (bookingId != null && bookingId.toString().isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            AppRouter.navigatorKey.currentState?.pushNamed(
              Routes.myBookings,
              arguments: bookingId.toString(),
            );
          });
        }
      }
    } catch (e) {
      debugPrint("⚠️ Error checking FCM initial message: $e");
    }

    // 10. جلب الـ Token (الرقم التعريفي للجهاز)
    String? token = await _fcm.getToken();
    debugPrint("🔑 FCM Device Token: $token");
  }

  // 🎨 دالة لعرض الإشعار من فوق والأبليكيشن مفتوح
  Future<void> _showLocalNotification(RemoteNotification notification, String? payload) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hanzbthalk_main_channel',
      'إشعارات هنظبطهالك الأساسية',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  /// جدولة إشعار تذكيري محلي قبل الحجز بمدة معينة
  Future<void> scheduleUpcomingBookingReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required Duration leadTime,
    String? payload,
  }) async {
    final now = DateTime.now();
    final reminderTime = scheduledDate.subtract(leadTime);
    if (reminderTime.isBefore(now)) {
      debugPrint("🔔 Booking reminder time is in the past ($reminderTime). Not scheduling.");
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hanzbthalk_main_channel',
      'تذكير بمواعيد الحجوزات',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    final scheduledTZDateTime = tz.TZDateTime.from(reminderTime, tz.local);

    try {
      await _localNotifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTZDateTime,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
      );
      debugPrint("🔔 Scheduled local reminder for booking #$id at $scheduledTZDateTime");
    } catch (e) {
      debugPrint("⚠️ Failed to schedule local notification: $e");
    }
  }

  /// عرض إشعار تجريبي محلي بعد 5 ثوانٍ
  Future<void> showTestNotification(String bookingId) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hanzbthalk_main_channel',
      'إشعارات الاختبار',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    final scheduledTZDateTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    try {
      await _localNotifications.zonedSchedule(
        id: 999, // ID ثابت للاختبار
        title: '🔔 تجربة حجز جديد (Hanzbthalk)',
        body: 'اضغط هنا لعرض تفاصيل الحجز وتجربة التأثير البصري!',
        scheduledDate: scheduledTZDateTime,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: bookingId,
      );
      debugPrint("🔔 Scheduled test notification for booking $bookingId in 5 seconds");
    } catch (e) {
      debugPrint("⚠️ zonedSchedule failed, showing immediately: $e");
      await _localNotifications.show(
        id: 999,
        title: '🔔 تجربة حجز جديد (Hanzbthalk)',
        body: 'اضغط هنا لعرض تفاصيل الحجز وتجربة التأثير البصري!',
        notificationDetails: platformDetails,
        payload: bookingId,
      );
    }
  }

  /// إلغاء جميع التذكيرات المحلية المجدولة
  Future<void> cancelAllReminders() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint("🔔 Cancelled all scheduled local reminders.");
    } catch (e) {
      debugPrint("⚠️ Failed to cancel scheduled local notifications: $e");
    }
  }
}