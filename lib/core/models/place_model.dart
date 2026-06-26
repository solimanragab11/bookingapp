import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';

class PlaceModel extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String type;
  final double latitude;
  final double longitude;
  final double rating;
  final List<dynamic> images;
  final String locationUrl;
  final String openingTime;
  final String closingTime;
  final double? minimumCharge;
  final String? menuPdfUrl;
  final List<String> subPlacesIds;
  final bool hasOffer;
  final String governorate; // 🌍 Governorate property

  const PlaceModel({
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
    required this.subPlacesIds,
    this.hasOffer = false,
    this.governorate = 'alexandria', // Default to cairo
  });

  factory PlaceModel.fromJson(
    Map<String, dynamic> json, [
    List<SubPlaceModel> subPlaces = const [],
  ]) {
    return PlaceModel(
      id: json['id'] as String? ?? '',
      ownerId: json['ownerId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
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
      subPlacesIds:
          (json['subPlacesIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      hasOffer: json['hasOffer'] as bool? ?? false,
      governorate:
          json['governorate'] as String? ?? 'cairo', // Parse governorate
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
      "subPlacesIds": subPlacesIds,
      "hasOffer": hasOffer,
      "governorate": governorate, // Serialize governorate
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
    List<dynamic>? images,
    String? locationUrl,
    String? openingTime,
    String? closingTime,
    double? minimumCharge,
    String? menuPdfUrl,
    List<String>? subPlacesIds,
    bool? hasOffer,
    String? governorate,
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
      subPlacesIds: subPlacesIds ?? this.subPlacesIds,
      hasOffer: hasOffer ?? this.hasOffer,
      governorate: governorate ?? this.governorate,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    description,
    type,
    latitude,
    longitude,
    rating,
    images,
    locationUrl,
    openingTime,
    closingTime,
    minimumCharge,
    menuPdfUrl,
    subPlacesIds,
    hasOffer,
    governorate,
  ];
}

class PlacesPageResult {
  final List<PlaceModel> places;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const PlacesPageResult({
    required this.places,
    required this.lastDocument,
    required this.hasMore,
  });
}
