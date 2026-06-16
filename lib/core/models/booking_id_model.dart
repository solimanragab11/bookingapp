import 'package:equatable/equatable.dart';

class BookingIdModel extends Equatable {
  final String bookingId;
  final String bookedBy; // 'user' or 'owner'
  final String bookername;
  final Map<String, List<String>> slots;

  const BookingIdModel({
    required this.bookingId,
    required this.bookedBy,
    required this.bookername,
    required this.slots,
  });

  factory BookingIdModel.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'];
    final Map<String, List<String>> parsedSlots = {};
    if (rawSlots is Map) {
      rawSlots.forEach((k, v) {
        if (v is List) {
          parsedSlots[k.toString()] = List<String>.from(v.map((e) => e.toString()));
        } else {
          parsedSlots[k.toString()] = [];
        }
      });
    }
    return BookingIdModel(
      bookingId: json['bookingId']?.toString() ?? '',
      bookedBy: json['bookedBy']?.toString() ?? 'user',
      bookername: json['bookername']?.toString() ?? 'user',
      slots: parsedSlots,
    );
  }

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'bookedBy': bookedBy,
    'bookername': bookername,
    'slots': slots,
  };

  @override
  List<Object?> get props => [bookingId, bookedBy, bookername, slots];
}
