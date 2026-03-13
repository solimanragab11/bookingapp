import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/user/home/widgets/place_card_skeleton.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/widgets/placecard.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_stats.dart';

class PlaceListView extends StatelessWidget {
  const PlaceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStats>(
      builder: (context, state) {
        // 1. حالة التحميل (Skeleton Loading)
        if (state is HomeLoading) {
          return ListView.builder(
            itemCount: 5, // بنعرض 5 كروت وهمية
            physics:
                const NeverScrollableScrollPhysics(), // عشان ما يلقلقش وقت التحميل
            itemBuilder: (context, index) => const PlaceCardSkeleton(),
          );
        }
        // 2. حالة نجاح التحميل (Display Data)
        else if (state is HomeLoaded) {
          if (state.places.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(), // لمسة الـ iOS الناعمة
            itemCount: state.places.length,
            itemBuilder: (context, index) {
              final place = state.places[index];
              return PlaceCard(
                place: place,
                onPressed: () => Navigator.pushNamed(
                  context,
                  Routes.placeDetails,
                  arguments: place,
                ),
                isAvailable: true,
              );
            },
          );
        }
        // 3. حالة الخطأ (Error State)
        else if (state is HomeError) {
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

  // ويدجت لو مفيش بيانات
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
            context.tr('no_places_found'),
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
