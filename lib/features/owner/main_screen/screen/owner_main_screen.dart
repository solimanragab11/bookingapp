import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/owner/main_screen/widgets/owner_main_screen_header.dart';
import 'package:hanzbthalk/features/owner/main_screen/widgets/states/empty_places_view.dart';
import 'package:hanzbthalk/features/owner/main_screen/widgets/states/error_places_view.dart';
import 'package:hanzbthalk/features/owner/main_screen/widgets/states/places_list_view.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_states.dart';

import 'package:hanzbthalk/core/db/permission_service.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';

class OwnerMainScreen extends StatelessWidget {
  const OwnerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentUser = context.read<AuthCubit>().currentUser;
    final canViewAnalytics =
        currentUser != null &&
        PermissionService.can(currentUser, 'viewAnalytics');

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      floatingActionButton: canViewAnalytics
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: FloatingActionButton(
                  backgroundColor: ColorManager.egyptianEarth.withOpacity(0.85),
                  elevation: 0,
                  hoverElevation: 0,
                  focusElevation: 0,
                  highlightElevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: ColorManager.emeraldGreen.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  onPressed: () {
                    // بنستخدم pushNamed عشان الـ Navigator يروح للـ AppRouter
                    Navigator.pushNamed(
                      context,
                      Routes.globalDashboard,
                      arguments: [''], // ابعت لستة الـ IDs اللي معاك هنا
                    );
                  },
                  child: const Icon(
                    Icons.space_dashboard_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : null,
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: Column(
              children: [
                const OwnerMainScreenHeader(),
                Expanded(
                  child:
                      BlocBuilder<
                        ManageBookingPlaceCubit,
                        ManageBookingPlaceState
                      >(
                        builder: (context, state) {
                          if (state is ManagePlaceLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: ColorManager.wasabi,
                              ),
                            );
                          } else if (state is ManagePlaceLoaded) {
                            return PlacesListView(places: state.places);
                          } else if (state is ManagePlaceEmpty) {
                            return const EmptyPlacesView();
                          } else if (state is ManagePlaceError) {
                            return ErrorPlacesView(message: state.message);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
