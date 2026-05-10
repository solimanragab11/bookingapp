import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/di/dependency_injection.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/dashboard_app_bar.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/date_display_banner.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/main_revenue_card.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/stats_grid.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/usage_performance_card.dart';
import '../logic/dashboard_cubit.dart';
import '../logic/dashboard_state.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final String placeId;
  const OwnerDashboardScreen({super.key, required this.placeId});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  DateTimeRange? selectedRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now.add(const Duration(days: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      // إنشاء الكوبيت باستخدام getIt
      create: (context) => getIt<DashboardCubit>()
        ..getRealTimeStats(
          widget.placeId,
          selectedRange!.start,
          selectedRange!.end,
        ),
      child: Builder(
        // 👈 السحر هنا: الـ Builder بيدي Context "تحت" الـ Provider
        builder: (context) {
          return Scaffold(
            backgroundColor: ColorManager.noirDeVigne,
            appBar: DashboardAppBar(
              onDatePicked: (range) {
                setState(() => selectedRange = range);
                // دلوقت الـ context ده شايف الـ Cubit بوضوح
                context.read<DashboardCubit>().getRealTimeStats(
                  widget.placeId,
                  range.start,
                  range.end,
                );
              },
            ),
            body: Stack(
              children: [
                BackGround(h: size.height, w: size.width),
                BlocBuilder<DashboardCubit, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ColorManager.wasabi,
                        ),
                      );
                    }

                    if (state is DashboardLoaded) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DateDisplayBanner(range: selectedRange!),
                            const SizedBox(height: 20),
                            MainRevenueCard(
                              totalRevenue:
                                  state.stats.totalAppRevenue +
                                  state.stats.totalManualRevenue,
                            ),
                            const SizedBox(height: 16),
                            StatsGrid(stats: state.stats),
                            const SizedBox(height: 16),
                            UsagePerformanceCard(
                              totalHours:
                                  state.stats.appHours +
                                  state
                                      .stats
                                      .manualHours, // أو إجمالي الساعات حسب الموديل بتاعك
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is DashboardError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
