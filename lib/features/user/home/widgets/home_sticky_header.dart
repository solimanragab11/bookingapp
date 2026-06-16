import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/home_header.dart';
import 'package:hanzbthalk/core/widgets/home_serachbar.dart';
import 'package:hanzbthalk/core/widgets/map_filter_bottomsheet.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_stats.dart';

class HomeStickyHeader extends StatelessWidget {
  final GlobalKey menuKey;
  final GlobalKey logoKey;
  final GlobalKey bookingsKey;
  final GlobalKey searchBarKey;
  final String selectedCategory;
  final String selectedTab;

  const HomeStickyHeader({
    super.key,
    required this.menuKey,
    required this.logoKey,
    required this.bookingsKey,
    required this.searchBarKey,
    required this.selectedCategory,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorManager.noirDeVigne,
            ColorManager.noirDeVigne,
            Color(0x00111A19),
          ],
          stops: [0.0, 0.85, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        left: w * 0.04,
        right: w * 0.04,
        top: MediaQuery.of(context).padding.top,
        bottom: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeHeader(
            menuKey: menuKey,
            logoKey: logoKey,
            bookingsKey: bookingsKey,
          ),
          const SizedBox(height: 5),
          BlocBuilder<HomeCubit, HomeStats>(
            builder: (context, state) {
              final isLoading = state is HomeLoading;
              final cubit = context.read<HomeCubit>();
              return HomeSearchBar(
                key: searchBarKey,
                isLoading: isLoading,
                isFilterActive:
                    cubit.filterLocation != null || cubit.filterDate != null,
                onFilterPressed: () async {
                  final result = await MapFilterBottomSheet.show(
                    context: context,
                    initialLocation: cubit.filterLocation,
                    initialRadiusKm: cubit.filterRadiusKm,
                    initialAddress: cubit.filterLocationAddress,
                    initialDate: cubit.filterDate,
                    initialStartHour: cubit.filterStartHour,
                    initialEndHour: cubit.filterEndHour,
                  );

                  if (result != null) {
                    if (result['clear'] == true) {
                      cubit.clearFilters();
                    } else {
                      cubit.applyMapAndTimeFilters(
                        location: result['location'] as LatLng?,
                        radiusKm: result['radiusKm'] as double?,
                        address: result['address'] as String?,
                        date: result['date'] as DateTime?,
                        startHour: result['startHour'] as String?,
                        endHour: result['endHour'] as String?,
                      );
                    }
                  }
                },
                onChanged: (value) {
                  cubit.searchPlaces(
                    selectedTab: selectedTab,
                    query: value,
                    category: selectedCategory,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
