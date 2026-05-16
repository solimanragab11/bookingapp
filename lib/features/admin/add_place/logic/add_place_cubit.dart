import 'dart:async';
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
  Timer? _searchDebounce;

  AddPlaceCubit(this._adminRepository) : super(AddPlaceState.initial());

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  // ─── Owner search ────────────────────────────────────────────────────────────

  Future<void> loadOwnerForEdit(String ownerId) async {
    if (ownerId.isEmpty) return;

    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null,
      ),
    );

    try {
      final UserModel? owner = await _adminRepository.getOwnerById(ownerId);

      if (owner != null && !isClosed) {
        emit(
          state.copyWith(
            selectedOwner: () => owner,
            place: state.place.copyWith(ownerId: owner.id),
            isLoading: false,
            errorMessage: () => null,
          ),
        );
      } else {
        _emitError('Could not find the owner for this place.');
      }
    } catch (e) {
      _emitError('Failed to load owner: ${e.toString()}');
    }
  }

  void searchOwner(String query) {
    if (query.length < 3) {
      emit(state.copyWith(searchResults: [], errorMessage: () => null));
      return;
    }

    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _adminRepository.searchOwners('+2$query');
        if (!isClosed) {
          emit(
            state.copyWith(searchResults: results, errorMessage: () => null),
          );
        }
      } catch (e) {
        _emitError('Search failed: ${e.toString()}');
      }
    });
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

  void updatePlace(PlaceModel newPlace) {
    emit(state.copyWith(place: newPlace, errorMessage: () => null));
  }

  // ─── Save New Place (Add Mode) ───────────────────────────────────────────────

  Future<void> savePlace() async {
    // ✅ نضمن تصفير الـ Success والـ Error مع بداية التحميل الجديد
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null,
      ),
    );

    try {
      await _adminRepository.uploadAndSavePlace(place: state.place);
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true, // 🔥 ستصل الآن كاملة ومستقرة للـ UI
            errorMessage: () => null,
          ),
        );
      }
    } catch (e) {
      _emitError("Save Place Failed: ${e.toString()}");
    }
  }

  // ─── Update Existing Place (Edit Mode) ───────────────────────────────────────

  Future<void> updateExistingPlace(PlaceModel place) async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null,
      ),
    );

    try {
      await _adminRepository.processPlaceUpdate(updatedPlace: place);
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true, // 🔥 ستصل الآن كاملة ومستقرة للـ UI
            errorMessage: () => null,
          ),
        );
      }
    } catch (e) {
      _emitError("Update Place Failed: ${e.toString()}");
    }
  }

  // ─── Image picking ───────────────────────────────────────────────────────────

  Future<List<File>> pickMainImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 60);
      return images.map((e) => File(e.path)).toList();
    } catch (e) {
      debugPrint('Error picking multi images: $e');
      return [];
    }
  }

  Future<File?> pickSubPlaceImage() async {
    try {
      final XFile? img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );
      return img != null ? File(img.path) : null;
    } catch (e) {
      debugPrint('Error picking sub-place image: $e');
      return null;
    }
  }

  // ─── Reset ───────────────────────────────────────────────────────────────────

  void reset() => emit(AddPlaceState.initial());

  // 🔥 ميثود جديدة لتصفير الـ Flags يتم استدعاؤها من الـ UI بعد عرض السناك بار أو الانتقال لشاشة أخرى
  void resetStatusFlags() {
    if (!isClosed) {
      emit(state.copyWith(isSuccess: false, errorMessage: () => null));
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────

  void _emitError(String message) {
    if (isClosed) return;

    // ✅ نكتفي ببعث الخطأ بوضوح وثبات بدون التسبب في سباق الـ microtask المربك للـ UI
    emit(
      state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: () => message,
      ),
    );
  }
}
