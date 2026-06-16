import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';

/// Generates the deterministic id used for a subplace belonging to [placeId]
/// at position [index] (0-based) in the subplaces list.
///
/// Format: `<placeId>_sub_<index>`
String generateSubPlaceId(String placeId, int index) {
  return '${placeId}_sub_$index';
}

/// Finds an existing [SubPlaceModel] with the given [id] inside
/// [existingSubPlaces], or returns null if none matches.
SubPlaceModel? findExistingSubPlace(
  String id,
  List<SubPlaceModel> existingSubPlaces,
) {
  for (final sp in existingSubPlaces) {
    if (sp.id == id) return sp;
  }
  return null;
}

/// Extracts the image path/url from a raw subplace map.
///
/// Supports both `File` objects (picked images, stored as `.path`) and
/// plain `String` values (existing urls).
String extractSubPlaceImagePath(Map<String, dynamic> data) {
  final image = data['image'];
  if (image == null) return '';
  // Avoid importing dart:io here to keep this file platform-agnostic;
  // any object exposing a `.path` getter (e.g. File) is supported.
  try {
    final dynamic path = (image as dynamic).path;
    if (path is String) return path;
  } catch (_) {
    // Not a File-like object, fall through.
  }
  if (image is String) return image;
  return image.toString();
}

/// Builds a single [SubPlaceModel] from raw UI [data] for the subplace at
/// [index] within [placeId].
///
/// If an existing subplace with the generated id is found in
/// [existingSubPlaces], its `slotsIds` are preserved. Otherwise the new
/// subplace starts with an empty `slotsIds` list (slots will be created
/// separately, see [buildNewSlotsModels]).
SubPlaceModel buildSubPlaceModel({
  required String placeId,
  required int index,
  required Map<String, dynamic> data,
  required List<SubPlaceModel> existingSubPlaces,
}) {
  final id = generateSubPlaceId(placeId, index);
  final existing = findExistingSubPlace(id, existingSubPlaces);

  return SubPlaceModel(
    id: id,
    imageUrl: extractSubPlaceImagePath(data),
    pricePerHour: double.tryParse(data['price']?.toString() ?? '') ?? 0.0,
    playersNumber: int.tryParse(data['playersNumber']?.toString() ?? '') ?? 0,
    slotsIds: existing?.slotsIds ?? [id],
  );
}

/// Builds the full list of [SubPlaceModel]s for [placeId] from raw UI
/// [subPlacesData], preserving slot references for subplaces that already
/// existed in [existingSubPlaces].
List<SubPlaceModel> buildAllSubPlaceModels({
  required String placeId,
  required List<Map<String, dynamic>> subPlacesData,
  required List<SubPlaceModel> existingSubPlaces,
}) {
  return [
    for (int i = 0; i < subPlacesData.length; i++)
      buildSubPlaceModel(
        placeId: placeId,
        index: i,
        data: subPlacesData[i],
        existingSubPlaces: existingSubPlaces,
      ),
  ];
}

/// Creates a fresh [SlotsModel] for a newly created subplace, pre-filled
/// with the default 10-day free time slots.
SlotsModel buildEmptySlotsForSubPlace(String subPlaceId) {
  return SlotsModel.fromJson({'id': subPlaceId});
}

/// Returns one new [SlotsModel] for every [SubPlaceModel] in
/// [subPlaceModels] that did NOT exist in [existingSubPlaces] (i.e. brand
/// new subplaces that need their slots document created).
List<SlotsModel> buildNewSlotsModels({
  required List<SubPlaceModel> subPlaceModels,
  required List<SubPlaceModel> existingSubPlaces,
}) {
  final existingIds = existingSubPlaces.map((sp) => sp.id).toSet();

  return [
    for (final sp in subPlaceModels)
      if (!existingIds.contains(sp.id)) buildEmptySlotsForSubPlace(sp.id),
  ];
}
