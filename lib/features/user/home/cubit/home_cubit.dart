// lib/features/user/home/cubit/home_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_stats.dart';
import 'package:remaking_booking_app_trail2/features/user/home/repos/home_repo.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

class HomeCubit extends Cubit<HomeStats> {
  final HomeRepoImpl _homeRepo;
  Timer? _searchDebounce;
  List<PlaceModel> _allPlaces = [];
  String _selectedTab = 'nearby';

  HomeCubit(this._homeRepo) : super(HomeLoading()) {
    fetchPlaces();
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  // 🗺️ دالة مساعدة لحساب المسافة بالكيلومتر
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

  // 💰 دالة محمية تجيب أقل سعر ملعب فرعي جوه المكان
  double _getLowestSubPlacePrice(PlaceModel place) {
    // استخدمنا try-catch عشان لو الداتا جاية ناقصة من الفايربيز الأبلكيشن ميكراشش
    try {
      if (place.subPlaces.isEmpty) return double.maxFinite;

      return place.subPlaces
          .map((sub) => (sub.pricePerHour).toDouble())
          .reduce((value, element) => value < element ? value : element);
    } catch (e) {
      return double.maxFinite;
    }
  }

  // 🔍 الدالة الأساسية للبحث
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
        final List<PlaceModel> allPlaces = await _homeRepo.getAllPlaces();
        final lowercaseQuery = query.toLowerCase();

        // 1. الفلترة الأساسية
        List<PlaceModel> filteredResults = allPlaces.where((place) {
          bool matchesQuery = place.name.toLowerCase().contains(lowercaseQuery);
          bool matchesCategory = category == 'all' || place.type == category;
          return matchesQuery && matchesCategory;
        }).toList();

        // 2. تحديث اللستة الأساسية عشان selectTab تستخدمها لو اليوزر غير التاب بدون بحث
        _allPlaces = filteredResults;

        // 3. بننادي على دالة ترتيب التابس عشان نطبق اللوجيك بتاع الـ Tabs
        _applyTabSortingAndEmit(filteredResults, _selectedTab);
      } catch (e) {
        emit(HomeError(message: e.toString()));
      }
    });
  }

  // 📦 جلب كل الأماكن
  Future<void> fetchPlaces() async {
    if (isClosed) return;
    emit(HomeLoading());
    try {
      _allPlaces = await _homeRepo.getAllPlaces();
      _applyTabSortingAndEmit(_allPlaces, _selectedTab);
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // 🏷️ جلب الأماكن حسب الفئة
  Future<void> getPlacesByCat(String cat) async {
    if (isClosed) return;
    emit(HomeLoading());
    try {
      if (cat == 'all') {
        await fetchPlaces();
        return; // 🛑 لازم الـ return دي عشان ما ينزلش يكمل ويعمل request بكلمة 'all'
      }
      _allPlaces = await _homeRepo.getPlacesByCat(cat);
      _applyTabSortingAndEmit(_allPlaces, _selectedTab);
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // 📑 عند الضغط على أي Tab (بدون ما يكتب في السيرش)
  Future<void> selectTab(String tab) async {
    _selectedTab = tab;
    if (isClosed) return;

    // بناخد نسخة من اللستة الحالية عشان نرتبها بدون ما نضرب الداتا الأصلية
    List<PlaceModel> currentPlaces = List.from(_allPlaces);

    emit(HomeLoading()); // بندي لودينج خفيف عشان اليوزر يحس بتغيير التاب
    await _applyTabSortingAndEmit(currentPlaces, tab);
  }

  // 👑 المايسترو: دالة خاصة بتطبيق ترتيب الـ Tabs عشان نمنع تكرار الكود
  Future<void> _applyTabSortingAndEmit(
    List<PlaceModel> places,
    String tab,
  ) async {
    List<PlaceModel> sortedPlaces = List.from(places);

    try {
      if (tab == "nearby") {
        // حماية صلاحيات الموقع
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
        emit(HomeLoaded(places: sortedPlaces, selectedTab: tab));
      }
    } catch (e) {
      // لو حصل أي خطأ (زي الـ GPS مقفول)، بنعرض اللستة زي ما هي بدون ترتيب عشان ما نقفلش الأبلكيشن
      print("Warning in Tab Sorting: $e");
      if (!isClosed) {
        emit(HomeLoaded(places: places, selectedTab: tab));
      }
    }
  }
}
