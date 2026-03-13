import 'package:remaking_booking_app_trail2/core/models/place.dart';

class ManagePlaceState {
  final Place place;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ManagePlaceState({
    required this.place,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ManagePlaceState copyWith({
    Place? place,
    bool? isLoading,
    String? Function()? errorMessage,
    bool? isSuccess,
  }) {
    return ManagePlaceState(
      place: place ?? this.place,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  factory ManagePlaceState.initial() {
    return ManagePlaceState(
      place: Place(
        id: '',
        ownerId: 'test_owner_id',
        name: '',
        description: '',
        type: '',
        latitude: 30.0444,
        longitude: 31.2357,
        images: [],
        locationUrl: '',
        openingTime: '09:00 AM',
        closingTime: '11:00 PM',
        subPlaces: [],
      ),
    );
  }
}
