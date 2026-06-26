import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hanzbthalk/core/models/offer_model.dart';

class BookingModel extends Equatable {
  final String id; // Unique ID for the booking
  final String userId;
  final String subPlaceId; // ID of the specific SubPlace being booked
  final String bookedBy; // ID of the specific SubPlace being booked
  final DateTime createdAt; // Date of the booking
  final Map<String, List<String>> timeSlots; // {"saturday": ["10:00", "11:00"]}
  final double totalPrice;
  final double paidAmount; // Amount paid (deposit or full amount)
  final double
  requiredDeposit; // Minimum deposit required based on hours booked
  final bool isOffer;
  final OfferModel? offer;
  final double priceAfterOffer;
  final String placeId;
  final bool isCash;
  final String status;
  final String checkInTime;
  final String? cashPin;
  final bool isCashSettled;

  const BookingModel({
    required this.bookedBy,
    required this.id,
    required this.userId,
    required this.subPlaceId,
    required this.createdAt,
    required this.timeSlots,
    required this.totalPrice,
    required this.paidAmount,
    required this.requiredDeposit,
    required this.isOffer,
    this.offer,
    required this.priceAfterOffer,
    required this.placeId,
    required this.isCash,
    required this.status,
    required this.checkInTime,
    this.cashPin,
    this.isCashSettled = false,
  });

  /// ---------- FROM JSON ----------
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    try {
      return BookingModel(
        bookedBy: json['bookedBy'] ?? '',
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        subPlaceId: json['subPlaceId'] ?? '',
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : (json['createdAt'] is String
                  ? DateTime.parse(json['createdAt'] as String)
                  : DateTime.now()),
        timeSlots: Map<String, List<String>>.from(
          json['timeSlots']?.map((k, v) => MapEntry(k, List<String>.from(v))) ??
              {},
        ),
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
        requiredDeposit: (json['requiredDeposit'] as num?)?.toDouble() ?? 0.0,
        isOffer: json['isOffer'] ?? false,
        offer: json['offer'] != null
            ? OfferModel.fromJson(json['offer'])
            : null,
        priceAfterOffer: (json['priceAfterOffer'] as num?)?.toDouble() ?? 0.0,
        placeId: json['placeId'] ?? '',
        status: json['status'] ?? '',
        isCash: json['isCash'] ?? false,
        checkInTime: json['checkInTime'] is Timestamp
            ? (json['checkInTime'] as Timestamp).toDate().toIso8601String()
            : (json['checkInTime'] as String? ?? ''),
        cashPin: json['cashPin'] as String?,
        isCashSettled: json['isCashSettled'] as bool? ?? false,
      );
    } catch (e, stackTrace) {
      debugPrint("❌ [BookingModel.fromJson] Failed to parse JSON: $json");
      debugPrint("❌ Error: $e");
      debugPrint("$stackTrace");
      rethrow;
    }
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'bookedBy': bookedBy,
      "id": id,
      "userId": userId,
      "subPlaceId": subPlaceId,
      "createdAt": createdAt.toIso8601String(),
      "timeSlots": timeSlots,
      "totalPrice": totalPrice,
      "paidAmount": paidAmount,
      "requiredDeposit": requiredDeposit,
      "isOffer": isOffer,
      "offer": offer?.toJson(),
      "priceAfterOffer": priceAfterOffer,
      "placeId": placeId,
      "isCash": isCash,
      "status": status,
      "checkInTime": checkInTime,
      "cashPin": cashPin,
      "isCashSettled": isCashSettled,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    subPlaceId,
    bookedBy,
    createdAt,
    timeSlots,
    totalPrice,
    paidAmount,
    requiredDeposit,
    isOffer,
    offer,
    priceAfterOffer,
    placeId,
    isCash,
    status,
    checkInTime,
    cashPin,
    isCashSettled,
  ];
}
