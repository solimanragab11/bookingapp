import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;
  final String placeId;
  final bool isWholePlace;
  final String? subPlaceId;
  final DateTime createdAt;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.validUntil,
    required this.validFrom,
    required this.placeId,
    required this.isWholePlace,
    this.subPlaceId,
    required this.createdAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return DateTime.now();
    }

    return OfferModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      validUntil: parseDateTime(json['validUntil']),
      validFrom: parseDateTime(json['validFrom']),
      placeId: json['placeId'] ?? '',
      isWholePlace: json['isWholePlace'] ?? false,
      createdAt: parseDateTime(json['createdAt']),
      subPlaceId: json['subPlaceId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'validUntil': validUntil.toIso8601String(),
      'validFrom': validFrom.toIso8601String(),
      'placeId': placeId,
      'isWholePlace': isWholePlace,
      'subPlaceId': subPlaceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        discountPercentage,
        validFrom,
        validUntil,
        placeId,
        isWholePlace,
        subPlaceId,
        createdAt,
      ];
}
