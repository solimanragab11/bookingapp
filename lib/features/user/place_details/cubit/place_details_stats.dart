// featurse/user/place_details/cubit/place_details_stats.dart
import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class PlaceDetailsStats {}

class PlaceDetailsInitial extends PlaceDetailsStats {}

class PlaceDetailsLoaded extends PlaceDetailsStats {
  final Place place;
  final int selectedSubPlaceIndex; // الفهرس بتاع الملعب اللي اليوزر اختاره
  final DateTime? selectedDate;

  PlaceDetailsLoaded({
    required this.place,
    this.selectedSubPlaceIndex = 0,
    this.selectedDate,
  });

  // ميثود ذكية عشان نحدث الـ State بسهولة
  PlaceDetailsLoaded copyWith({
    int? selectedSubPlaceIndex,
    DateTime? selectedDate,
  }) {
    return PlaceDetailsLoaded(
      place: place,
      selectedSubPlaceIndex:
          selectedSubPlaceIndex ?? this.selectedSubPlaceIndex,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class PlaceDetailsError extends PlaceDetailsStats {
  final String message;
  PlaceDetailsError(this.message);
}
