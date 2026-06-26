import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';

import 'package:hanzbthalk/features/owner/gloabal_dashboard/logic/global_dashboard_cubit.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/logic/global_dashboard_state.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/widgets/barchart.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/widgets/places_breakdown.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/widgets/summary_card.dart';

import 'package:hanzbthalk/core/db/permission_service.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';

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
                final currentUser = context.read<AuthCubit>().currentUser;
                final canViewAnalytics =
                    currentUser != null &&
                    PermissionService.can(currentUser, 'viewAnalytics');

                if (!canViewAnalytics) {
                  return Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: Center(
                          child: Text(
                            context.tr(
                              'permission_denied',
                              defaultValue: 'Permission Denied',
                            ),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

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
                                context,
                                report.totalRevenue,
                                report.totalBookingCount,
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
          Text(
            context.tr(
              'global_dashboard_title',
              defaultValue: 'Places Dashboard',
            ),
            style: const TextStyle(
              color: ColorManager.wasabi,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalSummary(
    BuildContext context,
    double revenue,
    int totalBookings,
  ) {
    return Row(
      children: [
        SummaryCard(
          title: context.tr('total_income', defaultValue: 'Total Income'),
          value: "${revenue.toInt()} ${context.tr('egp')}",
          color: Colors.amber,
          icon: Icons.monetization_on,
        ),
        const SizedBox(width: 12),
        SummaryCard(
          title: context.tr('total_bookings', defaultValue: 'Total Bookings'),
          value:
              "$totalBookings ${context.tr('bookings_count_unit', defaultValue: 'Bookings')}",
          color: ColorManager.wasabi,
          icon: Icons.event_available,
        ),
      ],
    );
  }
}
