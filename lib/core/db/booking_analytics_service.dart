import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart'; //

class BookingAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- 1. Low-Level Data Fetching (التجريد لجلب البيانات الخام) ---

  /// جلب الحجوزات الخام من السيرفر بناءً على المالك والفترة الزمنية
  Future<List<BookingModel>> getOwnerBookingsByDate({
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. هات الـ IDs بتاعة الأماكن اللي بيملكها الـ Owner ده
    final placesSnapshot = await FirebaseFirestore.instance
        .collection('places')
        .where('ownerId', isEqualTo: ownerId)
        .get();

    if (placesSnapshot.docs.isEmpty) return [];

    List<String> placeIds = placesSnapshot.docs.map((doc) => doc.id).toList();

    // 2. كويري الحجوزات مع فلتر التاريخ
    // ملاحظة: الـ ISO8601 string بيترتب صح أبجدياً (Lexicographical order)
    // فالمقارنة بـ isGreaterThanOrEqualTo هتشتغل تمام مع الـ String
    final bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('placeId', whereIn: placeIds) // فلتر الأماكن
        .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();

    return bookingsSnapshot.docs
        .map((doc) => BookingModel.fromJson(doc.data()))
        .toList();
  }

  // --- 2. Data Filtering (تجريد عملية الفلترة) ---

  List<BookingModel> filterByType(List<BookingModel> bookings, String type) {
    return bookings.where((b) => b.bookedBy == type).toList();
  }

  // --- 3. Calculation Engines (تجريد العمليات الحسابية) ---

  double calculateTotalRevenue(List<BookingModel> bookings) {
    return bookings.fold(0.0, (summ, b) => summ + b.priceAfterOffer);
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

    final allBookings = await getOwnerBookingsByDate(
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
    // 3. تحويل الخريطة (Map) إلى لستة من PlaceReport
    // بنستخدم Future.wait عشان نجمع كل الـ Futures اللي طالعة من الـ map
    List<PlaceReport> placesBreakdown = await Future.wait(
      bookingsByPlace.entries.map((entry) async {
        final PlaceModel? place = await getPlaceById(entry.key);

        return PlaceReport(
          placeName:
              place?.name ?? "unknownPlace", // حماية في حالة لو المكان ممسوح
          placeId: entry.key,
          bookingCount: entry.value.length,
          revenue: calculateTotalRevenue(entry.value),
        );
      }).toList(), // لازم نحولها لـ List عشان Future.wait يقبلها
    );

    return BookingMonthlyReport(
      month: month,
      ownerId: ownerId,
      totalBookingCount: allBookings.length,
      totalRevenue: totalRev,
      appBookingPercentage: calculatePercentage(
        appBookings.length,
        allBookings.length,
      ),
      placesBreakdown: placesBreakdown, // دلوقتى اللستة جاهزة ونوعها سليم 100%
    );
  }

  // --- 5. Utilities (وظائف إضافية مستقلة) ---

  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }

  Future<PlaceModel?> getPlaceById(String placeId) async {
    try {
      final doc = await _firestore.collection('places').doc(placeId).get();
      return doc.exists
          ? PlaceModel.fromJson(doc.data() as Map<String, dynamic>)
          : null;
    } catch (e) {
      debugPrint("خطأ أثناء جلب بيانات المكان $placeId: $e");
      return null;
    }
  }
}

/// تقرير فرعي لكل ملعب على حدة
class PlaceReport {
  final String placeId;
  final String placeName;
  final int bookingCount;
  final double revenue;

  PlaceReport({
    required this.placeName,
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
