import 'package:remaking_booking_app_trail2/core/db/booking_analytics_service.dart';

abstract class GlobalDashboardState {}

class GlobalDashboardInitial extends GlobalDashboardState {}

class GlobalDashboardLoading extends GlobalDashboardState {}

class GlobalDashboardLoaded extends GlobalDashboardState {
  // بنشيل الموديل الجديد اللي إنت لسه معرفه فوق
  final BookingMonthlyReport fullReport;

  GlobalDashboardLoaded(this.fullReport);
}

class GlobalDashboardError extends GlobalDashboardState {
  final String message;
  GlobalDashboardError(this.message);
}
