import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:remaking_booking_app_trail2/core/db/admin_services.dart';

class AdminDashBoardRepo {
  final AdminService _adminServices;

  AdminDashBoardRepo(this._adminServices);

  // 🔥 تحسين: جلب الأرقام في نفس اللحظة (Parallel) لتسريع الأداء بدلاً من الانتظار المتسلسل
  Future<Map<String, int>> getStaticStats() async {
    final results = await Future.wait([
      _adminServices.getPlacesCount(),
      _adminServices.getUsersCount(),
      _adminServices.getActiveOffersCount(),
    ]);

    return {
      'placesCount': results[0],
      'usersCount': results[1],
      'offersCount': results[2],
    };
  }

  // بتجيب الـ Income لوحده لايف
  Stream<double> getLiveIncomeStream() {
    return _adminServices.getTotalIncomeStream();
  }

  // تجميع الـ Futures (مرة واحدة) مع الـ Stream (لايف) في ستريم واحد مجمع للـ UI
  Stream<Map<String, dynamic>> getDashboardStatsStream() {
    return Rx.combineLatest4(
      Stream.fromFuture(_adminServices.getPlacesCount()),
      Stream.fromFuture(_adminServices.getUsersCount()),
      Stream.fromFuture(_adminServices.getActiveOffersCount()),
      _adminServices.getTotalIncomeStream(),
      (int places, int users, int offers, double income) {
        return {
          'placesCount': places,
          'usersCount': users,
          'offersCount': offers,
          'income': income,
        };
      },
    ).handleError((error) {
      // ✅ الطريقة الصحيحة لالتقاط الأخطاء داخل الـ Streams
      throw Exception("Repo Error: Failed to fetch live stats -> $error");
    });
  }

  // --- العمليات التي تظل Future لأنها أكشن لحظي (Delete / Update) ---

  Future<void> deletePlace(String placeId) async {
    try {
      await _adminServices.deletePlaceFromFirebase(placeId);
    } catch (e) {
      throw Exception("Repo Error: Failed to delete place -> $e");
    }
  }

  Future<void> changeUserRole(String userId, String newRole) async {
    try {
      await _adminServices.updateUserRoleInFirebase(userId, newRole);
    } catch (e) {
      throw Exception("Repo Error: Failed to update role -> $e");
    }
  }
}
