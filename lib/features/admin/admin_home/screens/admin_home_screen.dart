import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/core/widgets/home_serachbar.dart';
import 'package:hanzbthalk/features/admin/admin_home/widgets/admin_place_list_view.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/repos/home_repo.dart';
import 'package:hanzbthalk/features/user/home/widgets/home_tabs_section.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // 1. التعريف لازم يكون بره الـ build عشان يحافظ على قيمته
  String selectedCategory = 'all';
  String selectedTab = 'nearby';

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocProvider<HomeCubit>(
      create: (context) => HomeCubit(HomeRepoImpl(BookingService())),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            context.tr('appName'),
            style: TextStyleMangare.headingStyle.copyWith(
              fontSize: w * 0.065,
              color: ColorManager.wasabi,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              BackGround(h: h, w: w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: Column(
                  children: [
                    Builder(
                      builder: (blocContext) {
                        return HomeSearchBar(
                          onChanged: (value) {
                            // بننادي دالة السيرش باستخدام الـ Context المضمون وبدون setState عشوائي
                            blocContext.read<HomeCubit>().searchPlaces(
                              query: value,
                              category: selectedCategory,
                              selectedTab: selectedTab,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildCategoryList(),
                    const SizedBox(height: 15),
                    HomeTabsSection(currentTab: selectedTab),
                    const SizedBox(height: 15),
                    Expanded(
                      child: AdminPlaceListView(category: selectedCategory),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'name': 'All', 'icon': Icons.all_inclusive, 'id': 'all'},
      {'name': 'Football', 'icon': Icons.sports_soccer, 'id': 'football'},
      {'name': 'Padel', 'icon': Icons.sports_tennis, 'id': 'padel'},
      {'name': 'PS', 'icon': Icons.sports_esports, 'id': 'playstation'},
      {'name': 'Cafe', 'icon': Icons.local_cafe, 'id': 'cafe'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = selectedCategory == category['id'];

          return GestureDetector(
            // استخدام GestureDetector أفضل من IconButton عشان المربع كله يبقى قابل للضغط
            onTap: () {
              setState(() {
                selectedCategory = category['id'] as String;
              });
              // 3. هنا بتنادي الـ Cubit بتاعك عشان يفلتر الداتا فعلياً
              // context.read<HomeCubit>().getPlaces(category: selectedCategory);
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                // المربع بينور لو تم اختياره
                color: isSelected
                    ? ColorManager.creasedKhaki.withOpacity(0.3)
                    : ColorManager.wasabi.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected
                      ? ColorManager.creasedKhaki
                      : ColorManager.creasedKhaki.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 30,
                    color: isSelected
                        ? ColorManager.egyptianEarth
                        : ColorManager.wasabi,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? ColorManager.egyptianEarth
                          : ColorManager.wasabi,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
