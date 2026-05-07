import 'package:remaking_booking_app_trail2/core/models/subplace.dart';

class PlaceModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String type;
  final double latitude;
  final double longitude;
  final double rating;
  final List<String> images;
  final String locationUrl;
  final String openingTime;
  final String closingTime;
  final double? minimumCharge;
  final String? menuPdfUrl;
  final List<SubPlace> subPlaces;
  final bool hasOffer;

  PlaceModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.rating = 0.0,
    required this.images,
    required this.locationUrl,
    required this.openingTime,
    required this.closingTime,
    this.minimumCharge,
    this.menuPdfUrl,
    this.subPlaces = const [],
    this.hasOffer = false,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      // التعامل مع الأرقام بمرونة (Safe Casting)
      latitude: (json['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (json['longitude'] as num? ?? 0.0).toDouble(),
      rating: (json['rating'] as num? ?? 0.0).toDouble(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      locationUrl: json['locationUrl'] as String? ?? '',
      openingTime: json['openingTime'] as String? ?? '',
      closingTime: json['closingTime'] as String? ?? '',
      minimumCharge: (json['minimumCharge'] as num?)?.toDouble(),
      menuPdfUrl: json['menuPdfUrl'] as String?,

      // داخل factory Place.fromJson في ملف place.dart
      subPlaces: json['subPlaces'] == null
          ? []
          : (json['subPlaces'] is Map)
          // لو Firestore باعتها Map (بتحصل أحياناً في التحديثات)
          ? (json['subPlaces'] as Map).values
                .map((e) => SubPlace.fromJson(e as Map<String, dynamic>))
                .toList()
          // لو هي List طبيعية
          : (json['subPlaces'] as List)
                .map((e) => SubPlace.fromJson(e as Map<String, dynamic>))
                .toList(),
      hasOffer: json['hasOffer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "ownerId": ownerId,
      "name": name,
      "description": description,
      "type": type,
      "latitude": latitude,
      "longitude": longitude,
      "rating": rating,
      "images": images,
      "locationUrl": locationUrl,
      "openingTime": openingTime,
      "closingTime": closingTime,
      "minimumCharge": minimumCharge,
      "menuPdfUrl": menuPdfUrl,
      "subPlaces": subPlaces.map((e) => e.toJson()).toList(),
      "hasOffer": hasOffer,
    };
  }

  PlaceModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? type,
    double? latitude,
    double? longitude,
    double? rating,
    List<String>? images,
    String? locationUrl,
    String? openingTime,
    String? closingTime,
    double? minimumCharge,
    String? menuPdfUrl,
    List<SubPlace>? subPlaces,
    bool? hasOffer,
  }) {
    return PlaceModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      images: images ?? this.images,
      locationUrl: locationUrl ?? this.locationUrl,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      minimumCharge: minimumCharge ?? this.minimumCharge,
      menuPdfUrl: menuPdfUrl ?? this.menuPdfUrl,
      subPlaces: subPlaces ?? this.subPlaces,
      hasOffer: hasOffer ?? this.hasOffer,
    );
  }
}
