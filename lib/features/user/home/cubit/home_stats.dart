import 'package:equatable/equatable.dart';
import 'package:hanzbthalk/core/models/place_model.dart';

abstract class HomeStats extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeStatsInitial extends HomeStats {}

class HomeLoading extends HomeStats {}

class HomeLoaded extends HomeStats {
  final List<PlaceModel> places;
  final String selectedTab;

  HomeLoaded({required this.places, this.selectedTab = "nearby"});

  // 🔥 السطرين دول بيخلوا الـ Bloc يعرف إن الـ State اتغيرت لو لستة الملاعب اتغيرت!
  @override
  List<Object?> get props => [places, selectedTab];
}

class HomeError extends HomeStats {
  final String message;
  HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
