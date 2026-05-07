// lib/features/user/home/cubit/home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_stats.dart';
import 'package:remaking_booking_app_trail2/features/user/home/data/repos/home_repo.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';

class HomeCubit extends Cubit<HomeStats> {
  final HomeRepo _homeRepo;
  List<PlaceModel> _allPlaces = [];

  HomeCubit(this._homeRepo) : super(HomeLoading()) {
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    // جوه fetchPlaces
    if (isClosed) return; // ضيف السطر ده في بداية الدالة أو قبل الـ emit
    emit(HomeLoading());
    try {
      _allPlaces = await _homeRepo.getAllPlaces();
      emit(HomeLoaded(places: _allPlaces, selectedTab: "nearby"));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void selectTab(String tab) {
    if (state is HomeLoaded) {
      List<PlaceModel> filtered;
      if (tab == "offers") {
        filtered = _allPlaces.where((p) => p.hasOffer == true).toList();
      } else {
        filtered = _allPlaces;
      }
      emit(HomeLoaded(places: filtered, selectedTab: tab));
    }
  }
}
