import 'dart:async';
import 'package:rxdart/rxdart.dart'; // يفضل تضيف rxdart في الـ pubspec.yaml
import 'package:remaking_booking_app_trail2/core/db/admin_services.dart';

class AdminDashBoardRepo {
  final AdminService _adminServices;

  AdminDashBoardRepo(this._adminServices);

  // تحويل الميثود لـ Stream بدل Future لتعمل بشكل Live
  Stream<Map<String, dynamic>> getDashboardStatsStream() {
    try {
      // بنجمع كل الـ Streams من السيرفيس في Stream واحد مجمع
      return Rx.combineLatest4(
        _adminServices.getPlacesCountStream(),
        _adminServices.getUsersCountStream(),
        _adminServices.getActiveOffersCountStream(),
        _adminServices.getTotalIncomeStream(),
        (int places, int users, int offers, double income) {
          return {
            'placesCount': places,
            'usersCount': users,
            'offersCount': offers,
            'income': income,
          };
        },
      );
    } catch (e) {
      // في حالة الـ Streams، الـ Error بيمر عبر الـ Stream نفسه
      return Stream.error("Repo Error: Failed to fetch live stats -> $e");
    }
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
