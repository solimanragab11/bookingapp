import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/dashboard_states_model.dart';
import 'stat_card_item.dart';
import 'revenue_comparison_chart.dart';

class StatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final spacing = size.width * 0.03;

    return SingleChildScrollView(
      // 👈 حل مشكلة التداخل: السماح بالتمرير لو المساحة ضيقة
      physics: const NeverScrollableScrollPhysics(), // لو هو جوه قائمة تانية
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing),
        child: Column(
          children: [
            // الصف الأول: ماليات التطبيق (2 كروت)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: size.height * 0.18, // 👈 تثبيت ارتفاع موحد
                    child: StatCardItem(
                      title: context.tr('app_deposits'),
                      value: "${stats.totalAppDeposits} ${context.tr('egp')}",
                      icon: Icons.account_balance,
                      color: ColorManager.egyptianEarth,
                      subtitle: context.tr('money_held_by_app'),
                    ),
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: SizedBox(
                    height: size.height * 0.18,
                    child: StatCardItem(
                      title: context.tr('app_revenue'),
                      value: "${stats.totalAppRevenue} ${context.tr('egp')}",
                      icon: Icons.trending_up,
                      color: ColorManager.wasabi,
                      subtitle: context.tr('total_money__by_app'),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing),

            // الصف الثاني: شغل التطبيق (Full Row)
            SizedBox(
              width: double.infinity,
              height: size.height * 0.16,
              child: StatCardItem(
                title: context.tr('app_work'),
                value: "${stats.appHours} ${context.tr('hrs_unit')}",
                icon: Icons.history_toggle_off,
                color: ColorManager.creasedKhaki,
                subtitle: context.tr('hours_from_users'),
              ),
            ),

            SizedBox(height: spacing),

            // الصف الثالث: اليدوي والـ Chart (2 كروت)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height:
                        size.height *
                        0.2, // 👈 ارتفاع مناسب للرسم البياني والكرت
                    child: StatCardItem(
                      title: context.tr('manual_revenue'),
                      value: "${stats.totalManualRevenue} ${context.tr('egp')}",
                      icon: Icons.payments,
                      color: ColorManager.emeraldGreen,
                      subtitle: context.tr('cash_collected_by_you'),
                    ),
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: SizedBox(
                    height: size.height * 0.2,
                    child: RevenueComparisonChart(
                      appRevenue: stats.totalAppRevenue.toDouble(),
                      manualRevenue: stats.totalManualRevenue.toDouble(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: spacing),

            // الصف الرابع: عدد الحجوزات (Full Row)
            SizedBox(
              width: double.infinity,
              height: size.height * 0.2,
              child: StatCardItem(
                title: context.tr('resv_count'),
                value: "${stats.appCount} Vs ${stats.manualCount}",
                icon: Icons.analytics,
                color: ColorManager.egyptianEarth,
                subtitle: context.tr('app_vs_manual'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
