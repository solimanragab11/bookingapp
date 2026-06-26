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
  final bool isLoadingMore;
  final bool hasMore;

  HomeLoaded({
    required this.places,
    this.selectedTab = "nearby",
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [places, selectedTab, isLoadingMore, hasMore];
}

class HomeError extends HomeStats {
  final String message;
  HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
