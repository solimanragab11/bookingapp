// لازم الكلاس الأساسي يكون كدا
import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class HomeStats {}

class HomeStatsInitial extends HomeStats {}

class HomeLoading extends HomeStats {}

// هنا المشكلة.. لازم تضيف "extends HomeStats"
class HomeLoaded extends HomeStats {
  final List<Place> places;
  final String selectedTab;
  HomeLoaded({required this.places, this.selectedTab = "nearby"});
}

class HomeError extends HomeStats {
  final String message;
  HomeError({required this.message});
}

// لو لسه مستخدم HomeSelectTab ضيف لها الـ extends برضه
class HomeSelectTab extends HomeStats {
  final String selectedTab;
  final List<Place> places;
  HomeSelectTab({required this.selectedTab, required this.places});
}
