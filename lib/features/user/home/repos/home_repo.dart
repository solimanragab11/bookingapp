// lib/features/user/home/data/repos/home_repo.dart
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class HomeRepo {
  Future<List<PlaceModel>> getAllPlaces();
  Future<List<PlaceModel>> getPlacesByCat(String cat);
  Future<List<PlaceModel>> searchPlacesByName(String query);
}

class HomeRepoImpl implements HomeRepo {
  final BookingService _firebaseFunctions;

  HomeRepoImpl(this._firebaseFunctions);

  @override
  Future<List<PlaceModel>> getAllPlaces() async {
    // هنا بنقدر نهندل الـ Errors بشكل مركزي أو نغير مصدر البيانات
    return await _firebaseFunctions.getAllPlaces();
  }

  @override
  Future<List<PlaceModel>> searchPlacesByName(String query) async {
    // هنا بنقدر نهندل الـ Errors بشكل مركزي أو نغير مصدر البيانات

    return await _firebaseFunctions.getPlacesByName(query);
  }

  @override
  Future<List<PlaceModel>> getPlacesByCat(String cat) async {
    // هنا بنقدر نهندل الـ Errors بشكل مركزي أو نغير مصدر البيانات

    return await _firebaseFunctions.getPlacesByCat(cat);
  }
}
