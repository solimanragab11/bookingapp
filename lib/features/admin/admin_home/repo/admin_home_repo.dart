// lib/features/user/home/data/repos/home_repo.dart
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/models/place_model.dart';

abstract class AdminHomeRepo {
  Future<List<PlaceModel>> getAllPlaces();
}

class AdminHomeRepoImpl implements AdminHomeRepo {
  final BookingService _firebaseFunctions;

  AdminHomeRepoImpl(this._firebaseFunctions);

  @override
  Future<List<PlaceModel>> getAllPlaces() async {
    // هنا بنقدر نهندل الـ Errors بشكل مركزي أو نغير مصدر البيانات
    return await _firebaseFunctions.getAllPlaces();
  }
}
