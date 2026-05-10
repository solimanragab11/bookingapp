import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_analytics_service.dart';

class GlobalDashboardRepository {
  final BookingAnalyticsService _analyticsService;
  final AuthService _auth;
  GlobalDashboardRepository(this._analyticsService, this._auth);

  /// جلب التقرير الشامل للمالك (بما في ذلك تفاصيل كل ملعب للمقارنة)
  /// يعتمد الآن على [ownerId] بدلاً من قائمة الـ IDs
  Future<BookingMonthlyReport> fetchGlobalDashboardData({
    required DateTime month,
  }) async {
    try {
      // بننادي الميثود الجديدة اللي بتعمل الـ Abstraction والـ Grouping جوه الـ Service
      final ownerId = await _auth.getCurrentUserId();
      final report = await _analyticsService.getMonthlyReportByOwner(
        ownerId: ownerId!,
        month: month,
      );
      print(report.placesBreakdown.length);
      return report;
    } catch (e) {
      // رمي Exception واضح يساعدنا في الـ Debugging لو حصلت مشكلة في الـ Firestore
      throw Exception("❌ فشل في جلب بيانات لوحة التحكم العالمية: $e");
    }
  }
}
