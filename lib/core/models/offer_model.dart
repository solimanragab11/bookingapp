import 'package:equatable/equatable.dart';

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
    return OfferModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      validUntil: DateTime.parse(
        json['validUntil'] ?? DateTime.now().toIso8601String(),
      ),
      validFrom: DateTime.parse(
        json['validFrom'] ?? DateTime.now().toIso8601String(),
      ),
      placeId: json['placeId'] ?? '',
      isWholePlace: json['isWholePlace'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
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
