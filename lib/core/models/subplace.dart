import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/models/booking_id_model.dart';

class SubPlace {
  final String id;
  final String imageUrl;
  final double pricePerHour;
  final int playersNumber;

  Map<String, List<String>> freeTimeSlots;
  List<BookingIdModel> bookedTimeSlots;

  SubPlace({
    required this.id,
    required this.imageUrl,
    required this.pricePerHour,
    required this.playersNumber,
    Map<String, List<String>>? freeTimeSlots,
    List<BookingIdModel>? bookedTimeSlots,
  }) : freeTimeSlots = freeTimeSlots ?? _generateNext10DaysSlots(),
       bookedTimeSlots = bookedTimeSlots ?? [];

  static Map<String, List<String>> _generateNext10DaysSlots() {
    final Map<String, List<String>> slots = {};
    final now = DateTime.now();

    for (int i = 0; i < 10; i++) {
      final date = now.add(Duration(days: i));
      final String dayKey = DateFormat('EEEE dd/MM').format(date).toLowerCase();
      slots[dayKey] = List<String>.generate(24, (h) => "$h:00 - ${h + 1}:00");
    }
    return slots;
  }

  factory SubPlace.fromJson(Map<String, dynamic> json) {
    return SubPlace(
      id: json["id"] as String? ?? 'no-id',
      imageUrl: json["imageUrl"] as String? ?? '',
      pricePerHour: (json["pricePerHour"] as num? ?? 0.0).toDouble(),
      playersNumber: (json["playersNumber"] as num? ?? 0).toInt(),

      freeTimeSlots:
          (json["freeTimeSlots"] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v ?? [])),
          ) ??
          _generateNext10DaysSlots(),

      // هنا التعديل: التأكد من تحويل كل عنصر باستخدام FromJson المحدث في BookingIdModel
      bookedTimeSlots:
          (json["bookedTimeSlots"] as List?)
              ?.map(
                (item) => BookingIdModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "imageUrl": imageUrl,
      "pricePerHour": pricePerHour,
      "playersNumber": playersNumber,
      "freeTimeSlots": freeTimeSlots,
      // الـ toJson هنا هتنادي أوتوماتيكياً على الـ toJson المحدثة اللي فيها الـ bookedBy
      "bookedTimeSlots": bookedTimeSlots.map((item) => item.toJson()).toList(),
    };
  }

  SubPlace copyWith({
    String? id,
    String? imageUrl,
    double? pricePerHour,
    int? playersNumber,
    Map<String, List<String>>? freeTimeSlots,
    List<BookingIdModel>? bookedTimeSlots,
  }) {
    return SubPlace(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      playersNumber: playersNumber ?? this.playersNumber,
      freeTimeSlots: freeTimeSlots ?? this.freeTimeSlots,
      bookedTimeSlots: bookedTimeSlots ?? this.bookedTimeSlots,
    );
  }
}
