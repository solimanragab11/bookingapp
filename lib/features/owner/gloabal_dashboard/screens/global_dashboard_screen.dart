import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_analytics_service.dart'; // عشان الـ Models

import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/logic/global_dashboard_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/logic/global_dashboard_state.dart';

class GlobalDashboardScreen extends StatelessWidget {
  const GlobalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: BlocBuilder<GlobalDashboardCubit, GlobalDashboardState>(
              builder: (context, state) {
                if (state is GlobalDashboardLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.wasabi,
                    ),
                  );
                } else if (state is GlobalDashboardLoaded) {
                  // التقرير الشامل اللي راجع من الـ Repo
                  final report = state.fullReport;

                  return Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // 1. ملخص المالك (إجمالي كل الملاعب)
                              _buildGlobalSummary(
                                report.totalRevenue,
                                report
                                    .totalBookingCount, // استبدلنا الساعات بعدد الحجوزات أو ممكن تعدلها
                              ),
                              const SizedBox(height: 24),

                              // 2. الرسم البياني للمقارنة بين الملاعب
                              _buildComparisonChart(report.placesBreakdown),
                              const SizedBox(height: 24),

                              // 3. قائمة تفصيلية لكل ملعب للمقارنة
                              _buildPlacesBreakdown(report.placesBreakdown),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is GlobalDashboardError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets البناء ---

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "لوحة تحكم الملاعب",
            style: TextStyle(
              color: ColorManager.wasabi,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalSummary(double revenue, int totalBookings) {
    return Row(
      children: [
        _summaryCard(
          "إجمالي الدخل",
          "${revenue.toInt()} EGP",
          Colors.amber,
          Icons.monetization_on,
        ),
        const SizedBox(width: 12),
        _summaryCard(
          "إجمالي الحجوزات",
          "$totalBookings حجز",
          ColorManager.wasabi,
          Icons.event_available,
        ),
      ],
    );
  }

  Widget _buildComparisonChart(List<PlaceReport> places) {
    if (places.isEmpty) return const SizedBox();

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (places.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) *
              1.2),
          barGroups: places.asMap().entries.map((entry) {
            return _makeGroupData(
              entry.key,
              entry.value.revenue,
              entry.key % 2 == 0 ? ColorManager.wasabi : Colors.amber,
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < places.length) {
                    return Text(
                      "P${index + 1}", // اختصار لـ Place
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildPlacesBreakdown(List<PlaceReport> places) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "مقارنة أداء الملاعب",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.cardSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: ColorManager.wasabi.withOpacity(0.1),
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(color: ColorManager.wasabi),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ID: ${place.placeId.substring(0, 8)}...",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          "${place.bookingCount} حجز هذا الشهر",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${place.revenue.toInt()} EGP",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _summaryCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorManager.cardSurface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 0,
            color: Colors.white10,
          ),
        ),
      ],
    );
  }
}
