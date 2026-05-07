class DashboardStats {
  final double totalAppRevenue; // فلوس حجوزات الأبلكيشن
  final double totalManualRevenue; // فلوس الحجوزات اليدوية
  final int appReservationsCount; // عدد حجوزات الأبلكيشن
  final int manualReservationsCount; // عدد الحجوزات اليدوية
  final int totalBookedHours; // إجمالي الساعات

  DashboardStats({
    required this.totalAppRevenue,
    required this.totalManualRevenue,
    required this.appReservationsCount,
    required this.manualReservationsCount,
    required this.totalBookedHours,
  });

  double get totalRevenue => totalAppRevenue + totalManualRevenue;
}
