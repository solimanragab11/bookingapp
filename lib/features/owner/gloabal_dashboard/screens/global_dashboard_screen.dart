import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';

import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/logic/global_dashboard_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/logic/global_dashboard_state.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/widgets/barchart.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/widgets/places_breakdown.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/widgets/summary_card.dart';

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
                              BarchartCust(places: report.placesBreakdown),
                              const SizedBox(height: 24),

                              // 3. قائمة تفصيلية لكل ملعب للمقارنة
                              PlacesBreakdown(places: report.placesBreakdown),
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
        SummaryCard(
          title: "إجمالي الدخل",
          value: "${revenue.toInt()} EGP",
          color: Colors.amber,
          icon: Icons.monetization_on,
        ),
        const SizedBox(width: 12),
        SummaryCard(
          title: "إجمالي الحجوزات",
          value: "$totalBookings حجز",
          color: ColorManager.wasabi,
          icon: Icons.event_available,
        ),
      ],
    );
  }
}
