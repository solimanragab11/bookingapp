class DashboardStats {
  final double totalAppRevenue; // إجمالي قيمة حجوزات الأبلكيشن
  final double totalManualRevenue; // إجمالي قيمة الحجوزات اليدوية
  final double
  totalAppDeposits; // الفلوس اللي في محفظة الأبلكيشن فعلياً (عربون الأونلاين)
  final int appHours; // ساعات الأبلكيشن بس
  final int manualHours; // ساعات الـ Owner بس
  final int appCount;
  final int manualCount;

  DashboardStats({
    required this.totalAppRevenue,
    required this.totalManualRevenue,
    required this.totalAppDeposits,
    required this.appHours,
    required this.manualHours,
    required this.appCount,
    required this.manualCount,
  });

  int get totalHours => appHours + manualHours;
  double get totalRevenue => totalAppRevenue + totalManualRevenue;
}
