import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';

/// خدمة تحليلات الحجوزات
/// تُستخدم لتحليل بيانات الحجوزات وإنشاء التقارير الشهرية
class BookingAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// عد الحجوزات التي تمت عبر التطبيق (user-generated) في شهر معين
  /// يُستخدم لتتبع أداء الحجوزات عبر التطبيق
  Future<int> countAppBookingsForMonth({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('bookedBy', isEqualTo: 'user')
          .where('bookingDate', isGreaterThanOrEqualTo: firstDay.toUtc())
          .where('bookingDate', isLessThanOrEqualTo: lastDay.toUtc())
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ خطأ في عد حجوزات التطبيق: $e');
      rethrow;
    }
  }

  /// عد الحجوزات اليدوية (owner-generated) في شهر معين
  /// يُستخدم لتتبع الحجوزات التي تم إدخالها يدوياً بواسطة المالك
  Future<int> countOwnerBookingsForMonth({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('bookedBy', isEqualTo: 'owner')
          .where('bookingDate', isGreaterThanOrEqualTo: firstDay.toUtc())
          .where('bookingDate', isLessThanOrEqualTo: lastDay.toUtc())
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ خطأ في عد الحجوزات اليدوية: $e');
      rethrow;
    }
  }

  /// إجمالي عدد الحجوزات (app + owner) في شهر معين
  Future<int> countTotalBookingsForMonth({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('bookingDate', isGreaterThanOrEqualTo: firstDay.toUtc())
          .where('bookingDate', isLessThanOrEqualTo: lastDay.toUtc())
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ خطأ في عد إجمالي الحجوزات: $e');
      rethrow;
    }
  }

  /// جلب جميع حجوزات التطبيق (user) في شهر معين
  /// يُستخدم للحصول على التفاصيل الكاملة لحسابات الإيرادات والتقارير
  Future<List<BookingModel>> getAppBookingsForMonth({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('bookedBy', isEqualTo: 'user')
          .where('bookingDate', isGreaterThanOrEqualTo: firstDay.toUtc())
          .where('bookingDate', isLessThanOrEqualTo: lastDay.toUtc())
          .orderBy('bookingDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ خطأ في جلب حجوزات التطبيق: $e');
      rethrow;
    }
  }

  /// جلب جميع الحجوزات اليدوية (owner) في شهر معين
  Future<List<BookingModel>> getOwnerBookingsForMonth({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);

      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .where('bookedBy', isEqualTo: 'owner')
          .where('bookingDate', isGreaterThanOrEqualTo: firstDay.toUtc())
          .where('bookingDate', isLessThanOrEqualTo: lastDay.toUtc())
          .orderBy('bookingDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ خطأ في جلب الحجوزات اليدوية: $e');
      rethrow;
    }
  }

  /// حساب إجمالي الإيرادات من حجوزات التطبيق في شهر معين
  Future<double> calculateAppBookingRevenue({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final bookings = await getAppBookingsForMonth(
        placeId: placeId,
        month: month,
      );

      double totalRevenue = 0;
      for (var booking in bookings) {
        totalRevenue += booking.paidAmount;
      }

      debugPrint(
        '💰 إجمالي إيرادات حجوزات التطبيق: \$${totalRevenue.toStringAsFixed(2)}',
      );
      return totalRevenue;
    } catch (e) {
      debugPrint('❌ خطأ في حساب الإيرادات: $e');
      rethrow;
    }
  }

  /// حساب إجمالي الإيرادات من الحجوزات اليدوية
  Future<double> calculateOwnerBookingRevenue({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final bookings = await getOwnerBookingsForMonth(
        placeId: placeId,
        month: month,
      );

      double totalRevenue = 0;
      for (var booking in bookings) {
        totalRevenue += booking.paidAmount;
      }

      debugPrint(
        '💰 إجمالي إيرادات الحجوزات اليدوية: \$${totalRevenue.toStringAsFixed(2)}',
      );
      return totalRevenue;
    } catch (e) {
      debugPrint('❌ خطأ في حساب إيرادات الحجوزات اليدوية: $e');
      rethrow;
    }
  }

  /// حساب متوسط سعر الحجز (متوسط الإيرادات / عدد الحجوزات)
  Future<double> calculateAverageBookingValue({
    required String placeId,
    required DateTime month,
    required String bookedByType, // 'user' أو 'owner'
  }) async {
    try {
      if (bookedByType == 'user') {
        final count = await countAppBookingsForMonth(
          placeId: placeId,
          month: month,
        );
        final revenue = await calculateAppBookingRevenue(
          placeId: placeId,
          month: month,
        );
        return count > 0 ? revenue / count : 0;
      } else {
        final count = await countOwnerBookingsForMonth(
          placeId: placeId,
          month: month,
        );
        final revenue = await calculateOwnerBookingRevenue(
          placeId: placeId,
          month: month,
        );
        return count > 0 ? revenue / count : 0;
      }
    } catch (e) {
      debugPrint('❌ خطأ في حساب متوسط قيمة الحجز: $e');
      rethrow;
    }
  }

  /// الحصول على ملخص شامل للتحليلات الشهرية
  Future<BookingMonthlyReport> getMonthlyReport({
    required String placeId,
    required DateTime month,
  }) async {
    try {
      final appBookingCount = await countAppBookingsForMonth(
        placeId: placeId,
        month: month,
      );
      final ownerBookingCount = await countOwnerBookingsForMonth(
        placeId: placeId,
        month: month,
      );
      final appRevenue = await calculateAppBookingRevenue(
        placeId: placeId,
        month: month,
      );
      final ownerRevenue = await calculateOwnerBookingRevenue(
        placeId: placeId,
        month: month,
      );

      return BookingMonthlyReport(
        month: month,
        placeId: placeId,
        appBookingCount: appBookingCount,
        ownerBookingCount: ownerBookingCount,
        totalBookingCount: appBookingCount + ownerBookingCount,
        appBookingRevenue: appRevenue,
        ownerBookingRevenue: ownerRevenue,
        totalRevenue: appRevenue + ownerRevenue,
        appBookingPercentage: appBookingCount > 0
            ? (appBookingCount / (appBookingCount + ownerBookingCount)) * 100
            : 0,
      );
    } catch (e) {
      debugPrint('❌ خطأ في جلب التقرير الشهري: $e');
      rethrow;
    }
  }

  /// حذف جميع بيانات الحجوزات لمكان معين (للاختبار فقط)
  Future<void> deleteAllBookingsForPlace(String placeId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('placeId', isEqualTo: placeId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ تم حذف جميع الحجوزات للمكان $placeId');
    } catch (e) {
      debugPrint('❌ خطأ في حذف الحجوزات: $e');
      rethrow;
    }
  }
}

/// نموذج البيانات لتقرير الحجوزات الشهري
class BookingMonthlyReport {
  final DateTime month;
  final String placeId;
  final int appBookingCount; // حجوزات عبر التطبيق
  final int ownerBookingCount; // حجوزات يدوية
  final int totalBookingCount; // إجمالي الحجوزات
  final double appBookingRevenue; // إيرادات التطبيق
  final double ownerBookingRevenue; // إيرادات الحجوزات اليدوية
  final double totalRevenue; // إجمالي الإيرادات
  final double appBookingPercentage; // نسبة حجوزات التطبيق من الإجمالي

  BookingMonthlyReport({
    required this.month,
    required this.placeId,
    required this.appBookingCount,
    required this.ownerBookingCount,
    required this.totalBookingCount,
    required this.appBookingRevenue,
    required this.ownerBookingRevenue,
    required this.totalRevenue,
    required this.appBookingPercentage,
  });

  @override
  String toString() {
    return '''
═══════════════════════════════════════
📊 تقرير الحجوزات الشهري
═══════════════════════════════════════
📅 الشهر: ${month.month}/${month.year}
📍 المكان: $placeId

📊 عدد الحجوزات:
  • حجوزات التطبيق: $appBookingCount
  • الحجوزات اليدوية: $ownerBookingCount
  • الإجمالي: $totalBookingCount

💰 الإيرادات:
  • من التطبيق: \$${appBookingRevenue.toStringAsFixed(2)}
  • من الحجوزات اليدوية: \$${ownerBookingRevenue.toStringAsFixed(2)}
  • الإجمالي: \$${totalRevenue.toStringAsFixed(2)}

📈 النسب:
  • نسبة حجوزات التطبيق: ${appBookingPercentage.toStringAsFixed(2)}%
═══════════════════════════════════════
''';
  }
}
