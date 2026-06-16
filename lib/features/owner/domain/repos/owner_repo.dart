import 'package:dartz/dartz.dart';
import 'package:hanzbthalk/core/models/place_model.dart';

abstract class OwnerRepo {
  // إضافة مكان جديد (بترجع Either عشان لو فيه Error ترجع لنا String)
  Future<Either<String, Unit>> addPlace(PlaceModel place);

  // جلب الأماكن الخاصة بصاحب مكان معين
  Stream<Either<String, List<PlaceModel>>> getMyPlaces(String ownerId);

  // حذف مكان
  Future<Either<String, Unit>> deletePlace(String placeId);
}
