// featurse/user/place_details/cubit/place_details_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/features/user/place_details/cubit/place_details_stats.dart';

class PlaceDetailsCubit extends Cubit<PlaceDetailsStats> {
  // بنبدأ الـ Cubit وبنديله الـ PlaceModel اللي جاي من الـ Home
  PlaceDetailsCubit(PlaceModel place) : super(PlaceDetailsLoaded(place: place));

  // لما اليوزر يختار ملعب فرعي (SubPlace) مختلف
  void changeSubPlace(int index) {
    if (state is PlaceDetailsLoaded) {
      final currentState = state as PlaceDetailsLoaded;
      emit(currentState.copyWith(selectedSubPlaceIndex: index));
    }
  }

  // لما اليوزر يختار تاريخ معين للحجز
  void updateSelectedDate(DateTime date) {
    if (state is PlaceDetailsLoaded) {
      final currentState = state as PlaceDetailsLoaded;
      emit(currentState.copyWith(selectedDate: date));
    }
  }

  // ممكن هنا نزيد ميثود للـ Favorite لو حبيت مستقبلاً
}
