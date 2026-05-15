// لازم الكلاس الأساسي يكون كدا
import 'package:remaking_booking_app_trail2/core/models/place.dart';

abstract class AdminHomeStats {}

class HomeStatsInitial extends AdminHomeStats {}

class HomeLoading extends AdminHomeStats {}

// هنا المشكلة.. لازم تضيف "extends HomeStats"
class HomeLoaded extends AdminHomeStats {
  final List<PlaceModel> places;
  final String selectedTab;
  HomeLoaded({required this.places, this.selectedTab = "nearby"});
}

class HomeError extends AdminHomeStats {
  final String message;
  HomeError({required this.message});
}

// لو لسه مستخدم HomeSelectTab ضيف لها الـ extends برضه
class HomeSelectTab extends AdminHomeStats {
  final String selectedTab;
  final List<PlaceModel> places;
  HomeSelectTab({required this.selectedTab, required this.places});
}
