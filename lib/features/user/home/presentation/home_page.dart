import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/home_drawer.dart';
import 'package:remaking_booking_app_trail2/core/widgets/home_header.dart';
import 'package:remaking_booking_app_trail2/core/widgets/home_serachbar.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/data/repos/home_repo.dart';
import 'package:remaking_booking_app_trail2/features/user/home/widgets/home_tabs_section.dart';
import 'package:remaking_booking_app_trail2/features/user/home/widgets/place_list_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocProvider<HomeCubit>(
      create: (context) => HomeCubit(HomeRepoImpl(BookingService())),
      child: Scaffold(
        // إضافة الـ Drawer لتنظيم الأيقونات الزائدة
        drawer: const HomeDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              BackGround(h: h, w: w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: const Column(
                  children: [
                    HomeHeader(),
                    HomeSearchBar(),
                    SizedBox(height: 15),
                    HomeTabsSection(),
                    SizedBox(height: 15),
                    Expanded(child: PlaceListView()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
