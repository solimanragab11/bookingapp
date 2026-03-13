import 'package:remaking_booking_app_trail2/core/models/booking_model.dart';
import 'package:remaking_booking_app_trail2/core/models/offer.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

class UserModel {
  final String id;
  final String username;
  final String userRole;
  final String phoneNumber;
  final List<Place> favoraitsPlaces;
  final List<String> ownedPlaces;
  final List<BookingModel> bookedPlaces;
  final List<Offer> offers;
  final List<BookingModel> history;
  final int points;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.username,
    required this.userRole,
    required this.favoraitsPlaces,
    required this.ownedPlaces,
    required this.bookedPlaces,
    required this.offers,
    required this.history,
    required this.points,
  });

  /// ---------------- FROM JSON ----------------
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      userRole: json['userRole'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      favoraitsPlaces: (json['favoraitsPlaces'] as List<dynamic>? ?? [])
          .map((item) => Place.fromJson(item))
          .toList(),
      ownedPlaces: (json['ownedPlaces'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      bookedPlaces: (json['booked_places'] as List<dynamic>? ?? [])
          .map((item) => BookingModel.fromJson(item))
          .toList(),
      offers: (json['offers'] as List<dynamic>? ?? [])
          .map((item) => Offer.fromJson(item))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((item) => BookingModel.fromJson(item))
          .toList(),
      points: json['points'] ?? 0,
    );
  }

  /// ---------------- TO JSON ----------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'userRole': userRole,
      'phoneNumber': phoneNumber,
      'favoraitsPlaces': favoraitsPlaces.map((p) => p.toJson()).toList(),
      'ownedPlaces': ownedPlaces.toList(),
      'booked_places': bookedPlaces.map((p) => p.toJson()).toList(),
      'offers': offers.map((o) => o.toJson()).toList(),
      'history': history.map((b) => b.toJson()).toList(),
      'points': points,
    };
  }
}
