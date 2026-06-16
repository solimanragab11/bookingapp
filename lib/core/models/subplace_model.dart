import 'package:equatable/equatable.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';

class SubPlaceModel extends Equatable {
  final String id;
  final String imageUrl;
  final double pricePerHour;
  final int playersNumber;
  final List<String> slotsIds;

  const SubPlaceModel({
    required this.id,
    required this.imageUrl,
    required this.pricePerHour,
    required this.playersNumber,
    this.slotsIds = const [],
  });

  factory SubPlaceModel.fromJson(Map<String, dynamic> json) {
    return SubPlaceModel(
      id: json["id"] as String? ?? 'no-id',
      imageUrl: json["imageUrl"] as String? ?? '',
      pricePerHour: (json["pricePerHour"] as num? ?? 0.0).toDouble(),
      playersNumber: (json["playersNumber"] as num? ?? 0).toInt(),
      slotsIds:
          (json["slotsIds"] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "imageUrl": imageUrl,
      "pricePerHour": pricePerHour,
      "playersNumber": playersNumber,
      "slotsIds": slotsIds,
    };
  }

  SubPlaceModel copyWith({
    String? id,
    String? imageUrl,
    double? pricePerHour,
    int? playersNumber,
    Map<String, List<String>>? freeTimeSlots,
    List<BookingIdModel>? bookedTimeSlots,
    List<String>? slotsIds,
  }) {
    return SubPlaceModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      playersNumber: playersNumber ?? this.playersNumber,
      slotsIds: slotsIds ?? this.slotsIds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    pricePerHour,
    playersNumber,
    slotsIds,
  ];
}
