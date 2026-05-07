import 'package:equatable/equatable.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

enum ScheduleStatus { initial, loading, liveUpdate, actionSuccess, error }

class ScheduleState extends Equatable {
  // داتا الـ UI
  final DateTime selectedDate;
  final int selectedSubPlaceIndex;
  final List<String> selectedSlots;
  final bool? isSelectingBooked;
  final String? activeBookingId;
  // الـ Getter اللي ناقص يا بطل
  bool get hasSelection => selectedSlots.isNotEmpty;
  // داتا الـ Firestore والـ Status
  final PlaceModel? currentPlace; // المكان اللي بنراقبه
  final ScheduleStatus status;
  final String? errorMessage;

  const ScheduleState({
    required this.selectedDate,
    required this.selectedSubPlaceIndex,
    required this.selectedSlots,
    this.isSelectingBooked = false,
    this.activeBookingId,
    this.currentPlace,
    this.status = ScheduleStatus.initial,
    this.errorMessage,
  });

  factory ScheduleState.initial() {
    final now = DateTime.now();
    return ScheduleState(
      // بنصفر الوقت عشان المقارنات تكون دقيقة
      selectedDate: DateTime(now.year, now.month, now.day),
      selectedSubPlaceIndex: 0,
      selectedSlots: const [],
      isSelectingBooked: false,
      activeBookingId: null,
      currentPlace: null, // لسه معندناش داتا في البداية
      status: ScheduleStatus.initial,
      errorMessage: null,
    );
  }

  ScheduleState copyWith({
    DateTime? selectedDate,
    int? selectedSubPlaceIndex,
    List<String>? selectedSlots,
    bool? Function()? isSelectingBooked,
    String? Function()? activeBookingId,
    PlaceModel? currentPlace,
    ScheduleStatus? status,
    String? errorMessage,
  }) {
    return ScheduleState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSubPlaceIndex:
          selectedSubPlaceIndex ?? this.selectedSubPlaceIndex,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      isSelectingBooked: isSelectingBooked != null
          ? isSelectingBooked()
          : this.isSelectingBooked,
      activeBookingId: activeBookingId != null
          ? activeBookingId()
          : this.activeBookingId,
      currentPlace: currentPlace ?? this.currentPlace,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    selectedDate,
    selectedSubPlaceIndex,
    selectedSlots,
    isSelectingBooked,
    activeBookingId,
    currentPlace,
    status,
    errorMessage,
  ];
}
