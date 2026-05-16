import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/home_drawer.dart';
import 'package:remaking_booking_app_trail2/core/widgets/home_header.dart';
import 'package:remaking_booking_app_trail2/core/widgets/home_serachbar.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/repos/home_repo.dart';
import 'package:remaking_booking_app_trail2/features/user/home/widgets/home_tabs_section.dart';
import 'package:remaking_booking_app_trail2/features/user/home/widgets/place_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // الكاتيجوري محتفظين بقيمتها هنا بره الـ build
  String selectedCategory = 'all';
  String selectedTab = 'nearby';

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocProvider<HomeCubit>(
      // 1. هنا بنكريت الـ Cubit الأساسي للشاشة والـ Widgets اللي جواها
      create: (context) => HomeCubit(HomeRepoImpl(BookingService())),
      child: Scaffold(
        drawer: const HomeDrawer(),
        body: SafeArea(
          child: Stack(
            children: [
              BackGround(h: h, w: w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                child: Column(
                  children: [
                    const HomeHeader(),
                    const SizedBox(height: 10),

                    // 🚀 2. استخدام الـ Builder هنا هو السر! بيوفر blocContext تحت الـ Provider مباشرة
                    Builder(
                      builder: (blocContext) {
                        return HomeSearchBar(
                          onChanged: (value) {
                            // بننادي دالة السيرش باستخدام الـ Context المضمون وبدون setState عشوائي
                            blocContext.read<HomeCubit>().searchPlaces(
                              selectedTab: selectedTab,
                              query: value,
                              category: selectedCategory,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // 3. لستة الكاتيجوريز (لو ضغطت على وحدة، السيرش هيفلتر جواها برضه)
                    _buildCategoryList(),

                    const SizedBox(height: 15),
                    HomeTabsSection(currentTab: selectedTab),
                    const SizedBox(height: 15),

                    // 4. لستة عرض الملاعب اللي جواها الـ BlocBuilder والـ print بتاعك
                    Expanded(child: PlaceListView(category: selectedCategory)),
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
        // 🚀 استخدمنا Builder برضه جوه الـ ListView عشان الـ GestureDetector يعرف يوصل للـ Cubit صح
        itemBuilder: (categoryContext, index) {
          final category = categories[index];
          final bool isSelected = selectedCategory == category['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category['id'] as String;
              });

              // 👑 هنا بننادي الـ Cubit عشان يفلتر بالكاتيجوري الجديدة فوراً من السيرفر
              // استخدمنا الـ categoryContext المضمون هنا برضه
              categoryContext.read<HomeCubit>().getPlacesByCat(
                selectedCategory,
              );
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
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
