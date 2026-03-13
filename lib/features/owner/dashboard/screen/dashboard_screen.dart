import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_Wrapper_states.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/dashboard_header.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/states/empty_places_view.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/states/error_places_view.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/widgets/states/places_list_view.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_states.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  @override
  void initState() {
    super.initState();
    // بنجيب الـ ownerId من AuthCubit لو متوفر
    final authState = context.read<AuthCubit>().state;
    String? ownerId;
    if (authState is AuthSuccess && authState.role == 'owner') {
      ownerId = authState.user.id;
    }

    // fallback بسيط لو مفيش يوزر (ممكن تستبدله بـ redirect لاحقاً)
    ownerId ??= 'test_owner_id';

    context.read<ManageBookingPlaceCubit>().fetchMyPlaces(ownerId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorManager.wasabi,
        onPressed: () {
          Navigator.pushNamed(context, Routes.addPlace);
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Stack(
        children: [
          BackGround(h: size.height, w: size.width),
          SafeArea(
            child: Column(
              children: [
                const DashboardHeader(),
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
