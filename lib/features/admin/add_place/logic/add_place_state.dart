import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';

class AddPlaceState {
  final PlaceModel place;
  final List<SubPlaceModel> subPlaces;
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final List<UserModel> searchResults;
  final UserModel? selectedOwner;
  final double uploadProgress;
  AddPlaceState({
    required this.place,
    required this.subPlaces,
    this.isLoading = false,
    this.errorMessage,
    this.uploadProgress = 0,
    this.isSuccess = false,
    this.searchResults = const [],
    this.selectedOwner,
  });

  AddPlaceState copyWith({
    PlaceModel? place,
    bool? isLoading,
    // Use a wrapper so we can explicitly set errorMessage to null.
    // Pass `errorMessage: () => null` to clear it.
    // Pass `errorMessage: () => 'some error'` to set it.
    // Omit to keep the current value.
    String? Function()? errorMessage,
    bool? isSuccess,
    List<UserModel>? searchResults,
    UserModel? Function()? selectedOwner,
    double? uploadProgress,
    List<SubPlaceModel>? subPlaces,
  }) {
    return AddPlaceState(
      subPlaces: subPlaces ?? this.subPlaces,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      place: place ?? this.place,
      isLoading: isLoading ?? this.isLoading,
      // ← CRITICAL: always resolve via the wrapper; never carry stale errors
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
      searchResults: searchResults ?? this.searchResults,
      selectedOwner: selectedOwner != null
          ? selectedOwner()
          : this.selectedOwner,
    );
  }

  factory AddPlaceState.initial() {
    return AddPlaceState(
      place: PlaceModel(
        id: '',
        ownerId: '',
        name: '',
        description: '',
        type: '',
        latitude: 30.0444,
        longitude: 31.2357,
        images: [],
        locationUrl: '',
        openingTime: '09:00 AM',
        closingTime: '11:00 PM',
        subPlacesIds: const [],
      ),
      subPlaces: const [],
      searchResults: const [],
      selectedOwner: null,
    );
  }
}
