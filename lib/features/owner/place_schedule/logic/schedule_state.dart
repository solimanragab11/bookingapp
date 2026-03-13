import 'package:equatable/equatable.dart';

class ScheduleState extends Equatable {
  final DateTime selectedDate;
  final int selectedSubPlaceIndex;
  final List<String> selectedSlots;
  final bool? isSelectingBooked;

  const ScheduleState({
    required this.selectedDate,
    required this.selectedSubPlaceIndex,
    required this.selectedSlots,
    required this.isSelectingBooked,
  });

  factory ScheduleState.initial() {
    return ScheduleState(
      selectedDate: DateTime.now(),
      selectedSubPlaceIndex: 0,
      selectedSlots: const [],
      isSelectingBooked: null,
    );
  }

  ScheduleState copyWith({
    DateTime? selectedDate,
    int? selectedSubPlaceIndex,
    List<String>? selectedSlots,
    bool? Function()? isSelectingBooked,
  }) {
    return ScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSubPlaceIndex:
          selectedSubPlaceIndex ?? this.selectedSubPlaceIndex,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      isSelectingBooked: isSelectingBooked != null
          ? isSelectingBooked()
          : this.isSelectingBooked,
    );
  }

  bool get hasSelection => selectedSlots.isNotEmpty;

  @override
  List<Object?> get props =>
      [selectedDate, selectedSubPlaceIndex, selectedSlots, isSelectingBooked];
}

