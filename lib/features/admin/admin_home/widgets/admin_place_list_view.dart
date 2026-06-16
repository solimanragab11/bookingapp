import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/widgets/place_card.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_stats.dart';
import 'package:hanzbthalk/features/user/home/widgets/place_card_skeleton.dart';

class AdminPlaceListView extends StatelessWidget {
  const AdminPlaceListView({
    super.key,
    this.category,
  }); // صلحنا الاسم هنا لـ category
  final String?
  category; // خليناه String عشان يطابق الـ id اللي جاي من الـ Home

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStats>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return ListView.builder(
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

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: filteredPlaces.length,
            itemBuilder: (context, index) {
              final place = filteredPlaces[index];
              return PlaceCard(
                place: place, // بنبعت الـ place المفلتر علطول
                onPressed: () => {
                  Navigator.pushNamed(
                    context,
                    Routes.addPlace,
                    arguments: place, // بتبعت الأوبجكت اللي عايز تعدله هنا
                  ),
                },
                isAvailable: true,
              );
            },
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
            "لا توجد أماكن في هذه الفئة حالياً", // تقدر تستخدم context.tr هنا
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
