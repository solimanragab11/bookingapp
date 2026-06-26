import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';

abstract class AdminPlaceRepository {
  /// توليد ID جديد لمكان قبل حفظه
  String getNewPlaceId();

  /// جلب بيانات مكان معين
  Future<PlaceModel?> getPlaceById(String id);

  /// حفظ مكان جديد بالكامل (المكان + الملاعب الفرعية + المواعيد)
  Future<void> savePlaceData({
    required PlaceModel place,
    required List<SubPlaceModel> subPlaces,
    required List<SlotsModel> slotsList,
  });

  /// تحديث بيانات مكان موجود
  Future<void> updatePlaceWithSubPlaces({
    required PlaceModel place,
    required List<SubPlaceModel> allSubPlaces,
    required List<SlotsModel> allSlots,
    required Set<String> newSubPlaceIds,
  });

  /// مسح المكان بالكامل من قاعدة البيانات والصور من الـ Storage
  Future<void> completelyDeletePlace(PlaceModel place);
}
