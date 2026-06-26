import 'package:equatable/equatable.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/offer_model.dart';
import 'package:hanzbthalk/core/models/place_model.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String userRole;
  final String phoneNumber;
  final String fcmToken;
  final List<PlaceModel> favoraitsPlaces;
  final List<String> ownedPlaces;
  final List<BookingModel> bookedPlaces;
  final List<OfferModel> offers;
  final List<BookingModel> history;
  final int points;
  final String? ownerId;
  final List<String> assignedPlaceIds;
  final Map<String, bool> permissions;
  final int noShowCount;
  final int penaltyBookingsLeft;

  const UserModel({
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
    this.ownerId,
    this.assignedPlaceIds = const [],
    this.permissions = const {},
    this.noShowCount = 0,
    this.penaltyBookingsLeft = 0,
    required this.fcmToken,
  });

  /// ---------------- FROM JSON ----------------
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      userRole: json['userRole'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
      favoraitsPlaces: (json['favoraitsPlaces'] as List<dynamic>? ?? [])
          .map((item) => PlaceModel.fromJson(item))
          .toList(),
      ownedPlaces: (json['ownedPlaces'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      bookedPlaces: (json['booked_places'] as List<dynamic>? ?? [])
          .map((item) => BookingModel.fromJson(item))
          .toList(),
      offers: (json['offers'] as List<dynamic>? ?? [])
          .map((item) => OfferModel.fromJson(item))
          .toList(),
      history: (json['history'] as List<dynamic>? ?? [])
          .map((item) => BookingModel.fromJson(item))
          .toList(),
      points: json['points'] ?? 0,
      ownerId: json['ownerId'],
      assignedPlaceIds: (json['assignedPlaceIds'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      permissions:
          (json['permissions'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v == true),
          ) ??
          const {},
      noShowCount: json['noShowCount'] ?? 0,
      penaltyBookingsLeft: json['penaltyBookingsLeft'] ?? 0,
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
      if (ownerId != null) 'ownerId': ownerId,
      'assignedPlaceIds': assignedPlaceIds,
      'permissions': permissions,
      'noShowCount': noShowCount,
      'penaltyBookingsLeft': penaltyBookingsLeft,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? fcmToken,
    String? userRole,
    String? phoneNumber,
    List<PlaceModel>? favoraitsPlaces,
    List<String>? ownedPlaces,
    List<BookingModel>? bookedPlaces,
    List<OfferModel>? offers,
    List<BookingModel>? history,
    int? points,
    String? ownerId,
    List<String>? assignedPlaceIds,
    Map<String, bool>? permissions,
    int? noShowCount,
    int? penaltyBookingsLeft,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fcmToken: fcmToken ?? this.fcmToken,
      userRole: userRole ?? this.userRole,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      favoraitsPlaces: favoraitsPlaces ?? this.favoraitsPlaces,
      ownedPlaces: ownedPlaces ?? this.ownedPlaces,
      bookedPlaces: bookedPlaces ?? this.bookedPlaces,
      offers: offers ?? this.offers,
      history: history ?? this.history,
      points: points ?? this.points,
      ownerId: ownerId ?? this.ownerId,
      assignedPlaceIds: assignedPlaceIds ?? this.assignedPlaceIds,
      permissions: permissions ?? this.permissions,
      noShowCount: noShowCount ?? this.noShowCount,
      penaltyBookingsLeft: penaltyBookingsLeft ?? this.penaltyBookingsLeft,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    userRole,
    phoneNumber,
    favoraitsPlaces,
    ownedPlaces,
    bookedPlaces,
    offers,
    history,
    points,
    ownerId,
    assignedPlaceIds,
    permissions,
    noShowCount,
    penaltyBookingsLeft,
    fcmToken,
  ];
}
