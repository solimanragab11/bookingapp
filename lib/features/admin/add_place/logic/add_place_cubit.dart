import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/user_model.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/add_place_state.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/repo/add_place_repo.dart';

class AddPlaceCubit extends Cubit<AddPlaceState> {
  final AddPlaceRepo _adminRepository;
  final ImagePicker _picker = ImagePicker();

  AddPlaceCubit(this._adminRepository) : super(AddPlaceState.initial());

  // ─── Owner search ────────────────────────────────────────────────────────────

  void searchOwner(String query) async {
    if (query.length < 3) {
      emit(
        state.copyWith(
          searchResults: [],
          errorMessage: () => null, // clear any previous error
        ),
      );
      return;
    }

    try {
      final results = await _adminRepository.searchOwners('+2$query');
      emit(state.copyWith(searchResults: results, errorMessage: () => null));
    } catch (e) {
      _emitError('Search failed: ${e.toString()}');
    }
  }

  void selectOwner(UserModel owner) {
    emit(
      state.copyWith(
        selectedOwner: () => owner,
        searchResults: [],
        place: state.place.copyWith(ownerId: owner.id),
        errorMessage: () => null,
      ),
    );
  }

  void cancelSelection() {
    emit(
      state.copyWith(
        selectedOwner: () => null,
        searchResults: [],
        place: state.place.copyWith(ownerId: ''),
        errorMessage: () => null,
      ),
    );
  }

  // ─── Place data ──────────────────────────────────────────────────────────────

  /// Synchronously updates the place in state. No async, no side-effects.
  void updatePlace(PlaceModel newPlace) {
    emit(state.copyWith(place: newPlace, errorMessage: () => null));
  }

  // ─── Save ────────────────────────────────────────────────────────────────────

  Future<void> savePlace() async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null, // clear before new attempt
      ),
    );

    try {
      await _adminRepository.uploadAndSavePlace(place: state.place);
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      _emitError(e.toString());
    }
  }

  // ─── Image picking ───────────────────────────────────────────────────────────

  Future<List<File>> pickMainImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      return images.map((e) => File(e.path)).toList();
    } catch (e) {
      debugPrint('Error picking multi images: $e');
      return [];
    }
  }

  Future<File?> pickSubPlaceImage() async {
    try {
      final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
      return img != null ? File(img.path) : null;
    } catch (e) {
      debugPrint('Error picking sub-place image: $e');
      return null;
    }
  }

  // ─── Reset ───────────────────────────────────────────────────────────────────

  void reset() => emit(AddPlaceState.initial());

  // ─── Private helpers ─────────────────────────────────────────────────────────

  /// Emits an error state, then immediately schedules a follow-up emit
  /// that clears the error — so BlocListener only fires once and the
  /// error never bleeds into subsequent states.
  void _emitError(String message) {
    emit(
      state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: () => message,
      ),
    );
    // Clear after emitting so the error doesn't persist in state
    // and re-trigger the listener on the next unrelated rebuild.
    Future.microtask(() {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: () => null));
      }
    });
  }
}
