import 'package:equatable/equatable.dart';
import 'package:hanzbthalk/core/models/booking_id_model.dart';
import 'package:intl/intl.dart';

import 'package:flutter/foundation.dart';

class SlotsModel extends Equatable {
  final Map<String, List<String>> freeTimeSlots;
  final List<BookingIdModel> bookedTimeSlots;
  final Map<String, dynamic> lockedSlots; // key: slotId (day_slot), value: {userId, expiresAt}
  final String id;

  const SlotsModel({
    required this.freeTimeSlots,
    required this.bookedTimeSlots,
    this.lockedSlots = const {},
    required this.id,
  });

  static Map<String, List<String>> _generateNext10DaysSlots() {
    final Map<String, List<String>> slots = {};
    final now = DateTime.now();

    for (int i = 0; i < 10; i++) {
      final date = now.add(Duration(days: i));
      final String dayKey = DateFormat('EEEE dd/MM', 'en').format(date).toLowerCase();
      slots[dayKey] = List<String>.generate(24, (h) => "$h:00 - ${h + 1}:00");
    }
    return slots;
  }

  factory SlotsModel.fromJson(Map<String, dynamic> json) {
    final rawFree = json["freeTimeSlots"];
    Map<String, List<String>> parsedFree = {};
    if (rawFree is Map) {
      rawFree.forEach((k, v) {
        if (v is List) {
          parsedFree[k.toString()] = List<String>.from(
            v.map((e) => e.toString()),
          );
        } else {
          parsedFree[k.toString()] = [];
        }
      });
    } else {
      parsedFree = _generateNext10DaysSlots();
    }

    final rawBooked = json["bookedTimeSlots"];
    final List<BookingIdModel> parsedBooked = [];
    if (rawBooked is List) {
      for (var item in rawBooked) {
        if (item is Map) {
          try {
            final Map<String, dynamic> typedItem = Map<String, dynamic>.from(
              item,
            );
            parsedBooked.add(BookingIdModel.fromJson(typedItem));
          } catch (e) {
            debugPrint("SlotsModel parsing single booking error: $e");
          }
        }
      }
    } else if (rawBooked is Map) {
      rawBooked.forEach((k, v) {
        if (v is Map) {
          try {
            final Map<String, dynamic> typedItem = Map<String, dynamic>.from(v);
            parsedBooked.add(BookingIdModel.fromJson(typedItem));
          } catch (e) {
            debugPrint("SlotsModel parsing single booking map entry error: $e");
          }
        }
      });
    }

    final rawLocked = json["lockedSlots"];
    final Map<String, dynamic> parsedLocked = rawLocked is Map ? Map<String, dynamic>.from(rawLocked) : const {};

    return SlotsModel(
      freeTimeSlots: parsedFree,
      bookedTimeSlots: parsedBooked,
      lockedSlots: parsedLocked,
      id: json["id"] as String? ?? 'no-id',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "freeTimeSlots": freeTimeSlots,
      "bookedTimeSlots": bookedTimeSlots.map((item) => item.toJson()).toList(),
      "lockedSlots": lockedSlots,
    };
  }

  SlotsModel copyWith({
    String? id,
    Map<String, List<String>>? freeTimeSlots,
    List<BookingIdModel>? bookedTimeSlots,
    Map<String, dynamic>? lockedSlots,
  }) {
    return SlotsModel(
      freeTimeSlots: freeTimeSlots ?? this.freeTimeSlots,
      bookedTimeSlots: bookedTimeSlots ?? this.bookedTimeSlots,
      lockedSlots: lockedSlots ?? this.lockedSlots,
      id: id ?? this.id,
    );
  }

  @override
  List<Object?> get props => [id, freeTimeSlots, bookedTimeSlots, lockedSlots];
}
