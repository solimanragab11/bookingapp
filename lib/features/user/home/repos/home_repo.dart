// lib/features/user/home/data/repos/home_repo.dart
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';

abstract class HomeRepo {
  Future<List<PlaceModel>> getAllPlaces();
  Future<List<PlaceModel>> getPlacesByCat(String cat);
  Future<List<PlaceModel>> searchPlacesByName(String query);
  Future<List<SubPlaceModel>> getAllSubPlaces();
  Future<List<SlotsModel>> getAllSlots();
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

  @override
  Future<List<SubPlaceModel>> getAllSubPlaces() async {
    return await _firebaseFunctions.getAllSubPlaces();
  }

  @override
  Future<List<SlotsModel>> getAllSlots() async {
    return await _firebaseFunctions.getAllSlots();
  }
}
