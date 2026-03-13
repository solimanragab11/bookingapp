import 'package:intl/intl.dart';

class SubPlace {
  final String id;
  final String imageUrl;
  final double pricePerHour;
  final int playersNumber;

  Map<String, List<String>> freeTimeSlots;
  Map<String, List<String>> bookedTimeSlots;

  SubPlace({
    required this.id,
    required this.imageUrl,
    required this.pricePerHour,
    required this.playersNumber,
    Map<String, List<String>>? freeTimeSlots,
    Map<String, List<String>>? bookedTimeSlots,
  }) : freeTimeSlots =
           freeTimeSlots ?? _generateNext10DaysSlots(), // نستخدم ميثود موحدة
       bookedTimeSlots = bookedTimeSlots ?? {};

  // ميثود ثابتة لتوليد الساعات بالشكل اللي بتحبه "0:00 - 1:00"
  static Map<String, List<String>> _generateNext10DaysSlots() {
    final Map<String, List<String>> slots = {};
    final now = DateTime.now();

    for (int i = 0; i < 10; i++) {
      // 1. حساب تاريخ اليوم (اليوم الحالي + i)
      final date = now.add(Duration(days: i));

      // 2. تنسيق التاريخ (E: اسم اليوم اختصار، d/M: اليوم والشهر)
      // النتيجة هتكون مثلاً: Sunday 12/02
      final String dayKey = DateFormat('EEEE dd/MM').format(date).toLowerCase();

      // 3. توليد الساعات لهذا اليوم
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

      // هنا لو الداتا null من السيرفر، هيولد الساعات بالشكل الجديد فوراً
      freeTimeSlots:
          (json["freeTimeSlots"] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, List<String>.from(v ?? [])))
              .cast<String, List<String>>() ??
          _generateNext10DaysSlots(),

      bookedTimeSlots:
          (json["bookedTimeSlots"] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, List<String>.from(v ?? [])))
              .cast<String, List<String>>() ??
          {},
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "imageUrl": imageUrl,
      "pricePerHour": pricePerHour,
      "playersNumber": playersNumber,
      "freeTimeSlots": freeTimeSlots,
      "bookedTimeSlots": bookedTimeSlots,
    };
  }

  SubPlace copyWith({
    String? id,
    String? imageUrl,
    double? pricePerHour,
    int? playersNumber,
    Map<String, List<String>>? freeTimeSlots,
    Map<String, List<String>>? bookedTimeSlots,
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
