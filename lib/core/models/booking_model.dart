import 'package:remaking_booking_app_trail2/core/models/offer.dart';

class BookingModel {
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
  final Offer? offer;
  final double priceAfterOffer;
  final String placeId;
  final bool isCash;

  BookingModel({
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
  });

  /// ---------- FROM JSON ----------
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookedBy: json['bookedBy'] ?? '',
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      subPlaceId: json['subPlaceId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      timeSlots: Map<String, List<String>>.from(
        json['timeSlots']?.map((k, v) => MapEntry(k, List<String>.from(v))) ??
            {},
      ),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      requiredDeposit: (json['requiredDeposit'] as num?)?.toDouble() ?? 0.0,
      isOffer: json['isOffer'] ?? false,
      offer: json['offer'] != null ? Offer.fromJson(json['offer']) : null,
      priceAfterOffer: (json['priceAfterOffer'] as num?)?.toDouble() ?? 0.0,
      placeId: json['placeId'] ?? '',
      isCash: json['isCash'] ?? false,
    );
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
    };
  }
}
