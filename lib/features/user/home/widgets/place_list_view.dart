import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/place_card.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_stats.dart';
import 'package:hanzbthalk/features/user/home/widgets/place_card_skeleton.dart';

class PlaceListView extends StatelessWidget {
  final Key? firstCardKey;
  final String? category;

  const PlaceListView({super.key, this.category, this.firstCardKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStats>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: 5,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => const PlaceCardSkeleton(),
          );
        } else if (state is HomeLoaded) {
          // --- 1. هنا السحر: نفلتر القائمة بناءً على الكاتيجوري ---
          final filteredPlaces = category == null || category == 'all'
              ? state
                    .places // لو "all" هات كل الملاعب
              : state.places
                    .where((p) => p.type == category)
                    .toList(); // لو فئة معينة، هات اللي يخصها بس

          // --- 2. لو القائمة المفلترة فاضية، اعرض الـ Empty State ---
          if (filteredPlaces.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  return PlaceCard(
                    key: index == 0 ? firstCardKey : null,
                    place: place, // بنبعت الـ place المفلتر علطول
                    onPressed: () => Navigator.pushNamed(
                      context,
                      Routes.placeDetails,
                      arguments: place,
                    ),
                    isAvailable: true,
                  );
                },
              ),
              // 🔄 Loading More Indicator
              if (state.isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: ColorManager.egyptianEarth,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
              // End-of-list spacer
              if (!state.hasMore && filteredPlaces.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      '•  •  •',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 18,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
            ],
          );
        } else if (state is HomeError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('noPlacesInCategory'),
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
