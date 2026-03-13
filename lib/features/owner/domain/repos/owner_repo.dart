import 'package:dartz/dartz.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class OwnerRepo {
  // إضافة مكان جديد (بترجع Either عشان لو فيه Error ترجع لنا String)
  Future<Either<String, Unit>> addPlace(Place place);

  // جلب الأماكن الخاصة بصاحب مكان معين
  Future<Either<String, List<Place>>> getMyPlaces(String ownerId);

  // حذف مكان
  Future<Either<String, Unit>> deletePlace(String placeId);
}
