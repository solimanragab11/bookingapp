import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/slots_model.dart';
import 'package:equatable/equatable.dart';

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
  final List<SubPlaceModel> subPlaces; // الملاعب الفرعية
  final SlotsModel? currentSlots; // المواعيد الحالية للملعب المختار
  final ScheduleStatus status;
  final String? errorMessage;

  const ScheduleState({
    required this.selectedDate,
    required this.selectedSubPlaceIndex,
    required this.selectedSlots,
    this.isSelectingBooked = false,
    this.activeBookingId,
    this.currentPlace,
    this.subPlaces = const [],
    this.currentSlots,
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
      subPlaces: const [],
      currentSlots: null,
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
    List<SubPlaceModel>? subPlaces,
    SlotsModel? currentSlots,
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
      subPlaces: subPlaces ?? this.subPlaces,
      currentSlots: currentSlots ?? this.currentSlots,
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
    subPlaces,
    currentSlots,
    status,
    errorMessage,
  ];
}
