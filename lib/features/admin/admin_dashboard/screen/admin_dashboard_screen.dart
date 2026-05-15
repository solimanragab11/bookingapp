import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/admin_services.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dashboard/logic/admin_dashboard_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dashboard/logic/admin_dashboard_state.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dashboard/repo/admin_dashboard_repo.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dashboard/widgets/admin_actions_grid.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dashboard/widgets/admin_header.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dashboard/widgets/admin_stats_grid.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width > 600;

    return BlocProvider(
      create: (context) =>
          AdminDashboardCubit(AdminDashBoardRepo(AdminService()))
            ..getLiveStats(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            BackGround(h: size.height, w: size.width),
            SafeArea(
              child: BlocBuilder<AdminDashboardCubit, AdminDashboardState>(
                builder: (context, state) {
                  if (state is AdminDashboardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorManager.wasabi,
                      ),
                    );
                  } else if (state is AdminDashboardSuccess) {
                    // هنا بننادي الـ _buildBody اللي كانت ناقصة
                    return _buildBody(context, size, isTablet, state.stats);
                  } else if (state is AdminDashboardError) {
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
      ),
    );
  }

  // الميثود اللي كانت ناقصة (المسؤولة عن بناء محتوى الصفحة)
  Widget _buildBody(
    BuildContext context,
    Size size,
    bool isTablet,
    Map<String, dynamic> stats,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          AdminHeader(isTablet: isTablet, userName: 'Soliman'),
          const SizedBox(height: 30),
          Center(child: _buildSectionTitle(context, 'Statistics')),
          const SizedBox(height: 15),
          // بنبعت الـ stats للـ Widget اللي فصلناها
          AdminStatsGrid(isTablet: isTablet, stats: stats),
          const SizedBox(height: 30),
          _buildSectionTitle(context, 'Management'),
          const SizedBox(height: 15),
          AdminActionsGrid(isTablet: isTablet),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    return Text(
      context.tr(titleKey),
      style: const TextStyle(
        color: ColorManager.egyptianEarth,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
