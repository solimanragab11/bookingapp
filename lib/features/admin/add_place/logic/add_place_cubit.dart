import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_state.dart';
import 'package:hanzbthalk/features/admin/add_place/repo/add_place_repo.dart';

class AddPlaceCubit extends Cubit<AddPlaceState> {
  final AddPlaceRepo _adminRepository;
  final ImagePicker _picker = ImagePicker();
  Timer? _searchDebounce;
  StreamSubscription<TaskSnapshot>? _uploadSubscription;

  AddPlaceCubit(this._adminRepository) : super(AddPlaceState.initial());

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _uploadSubscription?.cancel();
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

  // --- REPLACE savePlace() with this version ---

  Future<void> savePlace(List<Map<String, dynamic>> subPlacesData) async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null,
        uploadProgress: 1.0,
      ),
    );

    try {
      await _adminRepository.uploadAndSavePlace(
        place: state.place,
        subPlacesData: subPlacesData,
        onProgress: (realProgress) {
          if (!isClosed) {
            emit(state.copyWith(uploadProgress: realProgress));
          }
        },
      );

      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            uploadProgress: 100.0,
            errorMessage: () => null,
          ),
        );
      }
    } catch (e) {
      _emitError("Save Place Failed: ${e.toString()}");
    }
  }

  // --- REPLACE updateExistingPlace() with this version ---

  Future<void> updateExistingPlace(
    PlaceModel place,
    List<Map<String, dynamic>> subPlacesData,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null,
        uploadProgress: 1.0,
      ),
    );

    try {
      await _adminRepository.processPlaceUpdate(
        updatedPlace: place,
        subPlacesData: subPlacesData,
        existingSubPlaces: state.subPlaces,
        onProgress: (realProgress) {
          if (!isClosed) {
            emit(state.copyWith(uploadProgress: realProgress));
          }
        },
      );

      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: true,
            uploadProgress: 100.0,
            errorMessage: () => null,
          ),
        );
      }
    } catch (e) {
      _emitError("Update Place Failed: ${e.toString()}");
    }
  }

  // --- Add this method too (near loadOwnerForEdit) ---

  /// Fetches the [SubPlaceModel]s referenced by [subPlacesIds] and stores
  /// them in state so the UI can pre-fill the subplaces step and slot
  /// references (`slotsIds`) can be preserved on save.
  Future<void> loadSubPlacesForEdit(List<String> subPlacesIds) async {
    if (subPlacesIds.isEmpty) return;

    try {
      final subPlaces = await _adminRepository.getSubPlacesByIds(subPlacesIds);

      if (!isClosed) {
        emit(state.copyWith(subPlaces: subPlaces, errorMessage: () => null));
      }
    } catch (e) {
      _emitError('Failed to load subplaces: ${e.toString()}');
    }
  }
  // ─── Place data ──────────────────────────────────────────────────────────────

  void updatePlace(PlaceModel newPlace) {
    emit(state.copyWith(place: newPlace, errorMessage: () => null));
  }

  // ─── 🛰️ الرفع المنفصل والمراقب لحظة بلحظة (Single Dynamic Upload) ───────────

  void uploadSingleImageWithProgress({
    required File file,
    required String folderPath,
  }) {
    emit(
      state.copyWith(
        isLoading: true,
        isSuccess: false,
        errorMessage: () => null,
        uploadProgress: 0.0,
      ),
    );

    try {
      final uploadTask = _adminRepository.startPlaceImageUpload(
        file: file,
        folderPath: folderPath,
      );

      _uploadSubscription?.cancel();

      _uploadSubscription = uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) async {
          double progress =
              (snapshot.bytesTransferred / snapshot.totalBytes) * 100;

          if (snapshot.state == TaskState.running) {
            if (!isClosed) {
              emit(state.copyWith(uploadProgress: progress));
            }
          } else if (snapshot.state == TaskState.success) {
            final String downloadUrl = await snapshot.ref.getDownloadURL();

            if (!isClosed) {
              emit(
                state.copyWith(
                  isLoading: false,
                  isSuccess: true,
                  uploadProgress: 100.0,
                  place: state.place.copyWith(
                    images: [...state.place.images, downloadUrl],
                  ),
                  errorMessage: () => null,
                ),
              );
            }
          }
        },
        onError: (error) {
          _emitError("Upload Image Failed: ${error.toString()}");
        },
      );
    } catch (e) {
      _emitError("Upload Trigger Failed: ${e.toString()}");
    }
  }

  // ─── Save New Place (Add Mode) ───────────────────────────────────────────────

  // ─── Update Existing Place (Edit Mode) ───────────────────────────────────────

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

  void resetStatusFlags() {
    if (!isClosed) {
      emit(state.copyWith(isSuccess: false, errorMessage: () => null));
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────

  void _emitError(String message) {
    if (isClosed) return;

    emit(
      state.copyWith(
        isLoading: false,
        isSuccess: false,
        uploadProgress: 0.0,
        errorMessage: () => message,
      ),
    );
  }

  void deletePlace(PlaceModel place) {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          isSuccess: false,
          errorMessage: () => null,
          uploadProgress: 1.0,
        ),
      );
      _adminRepository.completelyDeletePlace(place);
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          uploadProgress: 100.0,
          errorMessage: () => null,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
