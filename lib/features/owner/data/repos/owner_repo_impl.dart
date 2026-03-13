import 'package:dartz/dartz.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

import 'package:remaking_booking_app_trail2/features/owner/domain/repos/owner_repo.dart';

class OwnerRepoImpl implements OwnerRepo {
  final FirestoreOwnerService ownerService;

  OwnerRepoImpl(this.ownerService);

  @override
  Future<Either<String, Unit>> addPlace(Place place) async {
    try {
      await ownerService.addPlace(place);
      return right(unit);
    } catch (e) {
      return left("فشل إضافة المكان: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, List<Place>>> getMyPlaces(String ownerId) async {
    try {
      final places = await ownerService.getPlacesByOwner(ownerId);
      return right(places);
    } catch (e) {
      return left("فشل جلب البيانات: ${e.toString()}");
    }
  }

  @override
  Future<Either<String, Unit>> deletePlace(String placeId) async {
    try {
      // هنا محتاجين الـ ownerId عشان نعرف مسار الصور،
      // لو عندك الـ ownerId متوفر في مكان الاستدعاء عدّيه كـ باراميتر إضافي
      throw UnimplementedError(
        'Use OwnerBookingRepository / FirestoreOwnerService.deletePlaceWithImages instead.',
      );
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }

  @override
  Future<Either<String, Unit>> updateSubPlace(
    String placeId,
    String subPlaceId,
    Map<String, dynamic> data,
  ) async {
    try {
      await ownerService.updateSubPlaceDetails(placeId, subPlaceId, data);
      return right(unit);
    } catch (e) {
      return left(e.toString());
    }
  }
}
