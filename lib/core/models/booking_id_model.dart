class BookingIdModel {
  final String bookingId;
  final String bookedBy; // 'user' or 'owner'
  final String bookername;
  final Map<String, List<String>> slots;

  BookingIdModel({
    required this.bookingId,
    required this.bookedBy,
    required this.bookername,
    required this.slots,
  });

  factory BookingIdModel.fromJson(Map<String, dynamic> json) {
    return BookingIdModel(
      bookingId: json['bookingId'] ?? '',
      bookedBy: json['bookedBy'] ?? 'user', // default user
      bookername: json['bookername'] ?? 'user', // default user
      slots: (json['slots'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, List<String>.from(v)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'bookingId': bookingId,
    'bookedBy': bookedBy,
    'bookername': bookername,
    'slots': slots,
  };
}
