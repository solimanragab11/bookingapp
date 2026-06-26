import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_stats.dart';
import 'package:hanzbthalk/features/user/home/repos/home_repo.dart';
import 'package:hanzbthalk/core/models/place_model.dart';

class HomeCubit extends Cubit<HomeStats> {
  final HomeRepoImpl _homeRepo;
  Timer? _searchDebounce;
  List<PlaceModel> _allPlaces = [];
  String _selectedTab = 'nearby';

  // 🌍 Governorate & Pagination variables
  String selectedGovernorate = "alexandria";
  DocumentSnapshot? lastDocument;
  bool hasMore = true;
  bool isLoadingMore = false;

  LatLng? filterLocation;
  double? filterRadiusKm;
  String? filterLocationAddress;
  DateTime? filterDate;
  String? filterStartHour;
  String? filterEndHour;

  HomeCubit(this._homeRepo) : super(HomeLoading()) {
    fetchPlaces(isRefresh: true);
  }

  void clearFilters() {
    filterLocation = null;
    filterRadiusKm = null;
    filterLocationAddress = null;
    filterDate = null;
    filterStartHour = null;
    filterEndHour = null;
    fetchPlaces(isRefresh: true); // Reload all places for current governorate
  }

  void changeGovernorate(String governorate) {
    if (governorate.toLowerCase() != selectedGovernorate.toLowerCase()) {
      selectedGovernorate = governorate.toLowerCase();
      fetchPlaces(isRefresh: true);
    }
  }

  Future<void> fetchPlaces({bool isRefresh = true}) async {
    if (isClosed) return;
    if (isRefresh) {
      lastDocument = null;
      hasMore = true;
      isLoadingMore = false;
      _allPlaces = [];
      emit(HomeLoading());
    }
    try {
      final pageResult = await _homeRepo.getPlacesPaginated(
        governorate: selectedGovernorate,
        lastDocument: lastDocument,
        limit: 10,
      );

      _allPlaces.addAll(pageResult.places);
      lastDocument = pageResult.lastDocument;
      hasMore = pageResult.hasMore;
      isLoadingMore = false;

      _applyTabSortingAndEmit(_allPlaces, _selectedTab);
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> fetchNextPage() async {
    if (isClosed || isLoadingMore || !hasMore) return;
    isLoadingMore = true;

    if (state is HomeLoaded) {
      emit(HomeLoaded(
        places: _allPlaces,
        selectedTab: _selectedTab,
        isLoadingMore: true,
        hasMore: hasMore,
      ));
    }

    try {
      final pageResult = await _homeRepo.getPlacesPaginated(
        governorate: selectedGovernorate,
        lastDocument: lastDocument,
        limit: 10,
      );

      _allPlaces.addAll(pageResult.places);
      lastDocument = pageResult.lastDocument;
      hasMore = pageResult.hasMore;
      isLoadingMore = false;

      _applyTabSortingAndEmit(_allPlaces, _selectedTab);
    } catch (e) {
      isLoadingMore = false;
      emit(HomeLoaded(
        places: _allPlaces,
        selectedTab: _selectedTab,
        isLoadingMore: false,
        hasMore: hasMore,
      ));
    }
  }

  Future<void> applyMapAndTimeFilters({
    LatLng? location,
    double? radiusKm,
    String? address,
    DateTime? date,
    String? startHour,
    String? endHour,
  }) async {
    filterLocation = location;
    filterRadiusKm = radiusKm;
    filterLocationAddress = address;
    filterDate = date;
    filterStartHour = startHour;
    filterEndHour = endHour;

    if (isClosed) return;
    emit(HomeLoading());

    try {
      final List<PlaceModel> allPlaces =
          await _homeRepo.getPlacesByGovernorate(selectedGovernorate);
      List<PlaceModel> filtered = List.from(allPlaces);

      // 1. Filter by Location & Radius
      if (location != null && radiusKm != null) {
        filtered = filtered.where((place) {
          double dist = _calculateDistance(
            location.latitude,
            location.longitude,
            place.latitude,
            place.longitude,
          );
          return dist <= radiusKm;
        }).toList();
      }

      // 2. Filter by Date & Time slots availability
      if (date != null && startHour != null && endHour != null) {
        final dayKey = DateFormat('EEEE dd/MM', 'en').format(date).toLowerCase();
        final requestedSlots = _generateSlotsInRange(startHour, endHour);

        if (requestedSlots.isNotEmpty) {
          final allSlots = await _homeRepo.getAllSlots();
          final slotsMap = {for (var s in allSlots) s.id: s};

          filtered = filtered.where((place) {
            return place.subPlacesIds.any((subPlaceId) {
              final subPlaceSlots = slotsMap[subPlaceId];
              if (subPlaceSlots == null) return false;
              final freeSlots = subPlaceSlots.freeTimeSlots[dayKey] ?? [];
              return requestedSlots.every((slot) => freeSlots.contains(slot));
            });
          }).toList();
        }
      }

      _allPlaces = filtered;
      _applyTabSortingAndEmit(filtered, _selectedTab);
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  List<String> _generateSlotsInRange(String start, String end) {
    List<String> slots = [];
    try {
      int startH = int.parse(start.split(':')[0]);
      int endH = int.parse(end.split(':')[0]);
      if (endH <= startH) return [];
      for (int h = startH; h < endH; h++) {
        slots.add("$h:00 - ${h + 1}:00");
      }
    } catch (_) {}
    return slots;
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  double _calculateDistance(
    double userLat,
    double userLng,
    double? placeLat,
    double? placeLng,
  ) {
    if (placeLat == null || placeLng == null) return double.maxFinite;
    return Geolocator.distanceBetween(userLat, userLng, placeLat, placeLng) /
        1000;
  }

  double _getLowestSubPlacePrice(PlaceModel place) {
    return place.minimumCharge ?? 0.0;
  }

  void searchPlaces({
    required String query,
    required String category,
    required String selectedTab,
  }) {
    _selectedTab = selectedTab;
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.trim().isEmpty) {
      getPlacesByCat(category);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (isClosed) return;
      emit(HomeLoading());

      try {
        final List<PlaceModel> allPlaces =
            await _homeRepo.getPlacesByGovernorate(selectedGovernorate);
        final lowercaseQuery = query.toLowerCase();

        List<PlaceModel> filteredResults = allPlaces.where((place) {
          bool matchesQuery = place.name.toLowerCase().contains(lowercaseQuery);
          bool matchesCategory = category == 'all' || place.type == category;
          return matchesQuery && matchesCategory;
        }).toList();

        _allPlaces = filteredResults;
        _applyTabSortingAndEmit(filteredResults, _selectedTab);
      } catch (e) {
        emit(HomeError(message: e.toString()));
      }
    });
  }



  Future<void> getPlacesByCat(String cat) async {
    if (isClosed) return;
    emit(HomeLoading());
    try {
      if (cat == 'all') {
        await fetchPlaces(isRefresh: true);
        return;
      }
      final allPlaces =
          await _homeRepo.getPlacesByGovernorate(selectedGovernorate);
      _allPlaces = allPlaces.where((p) => p.type == cat).toList();
      _applyTabSortingAndEmit(_allPlaces, _selectedTab);
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> selectTab(String tab) async {
    _selectedTab = tab;
    if (isClosed) return;

    List<PlaceModel> currentPlaces = List.from(_allPlaces);

    emit(HomeLoading());
    await _applyTabSortingAndEmit(currentPlaces, tab);
  }

  Future<void> _applyTabSortingAndEmit(
    List<PlaceModel> places,
    String tab,
  ) async {
    List<PlaceModel> sortedPlaces = List.from(places);

    try {
      if (tab == "nearby") {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          sortedPlaces.sort((a, b) {
            double distA = _calculateDistance(
              position.latitude,
              position.longitude,
              a.latitude,
              a.longitude,
            );
            double distB = _calculateDistance(
              position.latitude,
              position.longitude,
              b.latitude,
              b.longitude,
            );
            return distA.compareTo(distB);
          });
        }
      } else if (tab == "offers") {
        sortedPlaces = sortedPlaces.where((p) => p.hasOffer == true).toList();
      } else if (tab == "lowestprice") {
        sortedPlaces.sort((a, b) {
          return _getLowestSubPlacePrice(
            a,
          ).compareTo(_getLowestSubPlacePrice(b));
        });
      }

      if (!isClosed) {
        emit(HomeLoaded(
          places: sortedPlaces,
          selectedTab: tab,
          isLoadingMore: isLoadingMore,
          hasMore: hasMore,
        ));
      }
    } catch (e) {
      debugPrint("Warning in Tab Sorting: $e");
      if (!isClosed) {
        emit(HomeLoaded(
          places: places,
          selectedTab: tab,
          isLoadingMore: isLoadingMore,
          hasMore: hasMore,
        ));
      }
    }
  }
}
