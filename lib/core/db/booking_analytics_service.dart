import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_model.dart'; //

class BookingAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. Low-Level Data Fetching (التجريد لجلب البيانات الخام) ---

  /// جلب الحجوزات الخام من السيرفر بناءً على المالك والفترة الزمنية
  Future<List<BookingModel>> fetchRawBookings({
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('ownerId', isEqualTo: ownerId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: startDate.toIso8601String(),
          )
          .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();
      return snapshot.docs
          .map((doc) => BookingModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching bookings: $e');
      rethrow;
    }
  }

  // --- 2. Data Filtering (تجريد عملية الفلترة) ---

  List<BookingModel> filterByType(List<BookingModel> bookings, String type) {
    return bookings.where((b) => b.bookedBy == type).toList();
  }

  // --- 3. Calculation Engines (تجريد العمليات الحسابية) ---

  double calculateTotalRevenue(List<BookingModel> bookings) {
    return bookings.fold(0.0, (summ, b) => summ + b.paidAmount);
  }

  double calculateAverageValue(double totalRevenue, int count) {
    return count > 0 ? totalRevenue / count : 0.0;
  }

  double calculatePercentage(int part, int total) {
    return total > 0 ? (part / total) * 100 : 0.0;
  }

  // --- 4. Business Logic Abstraction (تجميع البيانات في تقرير) ---

  /// الميثود دي بتجمع الأجزاء الصغيرة عشان تبني التقرير
  Future<BookingMonthlyReport> getMonthlyReportByOwner({
    required String ownerId,
    required DateTime month,
  }) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final allBookings = await fetchRawBookings(
      ownerId: ownerId,
      startDate: firstDay,
      endDate: lastDay,
    );

    // 1. حساب الإحصائيات العامة كالعادة
    final appBookings = filterByType(allBookings, 'user');
    final totalRev = calculateTotalRevenue(allBookings);

    // 2. تقسيم الحجوزات بناءً على الـ placeId للمقارنة
    Map<String, List<BookingModel>> bookingsByPlace = {};
    for (var booking in allBookings) {
      bookingsByPlace.putIfAbsent(booking.placeId, () => []).add(booking);
    }

    // 3. تحويل الخريطة (Map) إلى لستة من PlaceReport
    List<PlaceReport> placesBreakdown = bookingsByPlace.entries.map((entry) {
      return PlaceReport(
        placeId: entry.key,
        bookingCount: entry.value.length,
        revenue: calculateTotalRevenue(entry.value),
      );
    }).toList();

    return BookingMonthlyReport(
      month: month,
      ownerId: ownerId,
      totalBookingCount: allBookings.length,
      totalRevenue: totalRev,
      appBookingPercentage: calculatePercentage(
        appBookings.length,
        allBookings.length,
      ),
      placesBreakdown: placesBreakdown, // اللستة جاهزة للمقارنة
    );
  }

  // --- 5. Utilities (وظائف إضافية مستقلة) ---

  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }
}

/// تقرير فرعي لكل ملعب على حدة
class PlaceReport {
  final String placeId;
  final int bookingCount;
  final double revenue;

  PlaceReport({
    required this.placeId,
    required this.bookingCount,
    required this.revenue,
  });
}

/// تقرير التحليلات الشامل للمالك
class BookingMonthlyReport {
  final DateTime month;
  final String ownerId;
  final int totalBookingCount;
  final double totalRevenue;
  final double appBookingPercentage;
  // اللستة دي هي اللي هنعمل بيها المقارنة في الـ UI
  final List<PlaceReport> placesBreakdown;

  BookingMonthlyReport({
    required this.month,
    required this.ownerId,
    required this.totalBookingCount,
    required this.totalRevenue,
    required this.appBookingPercentage,
    required this.placesBreakdown,
  });
}
