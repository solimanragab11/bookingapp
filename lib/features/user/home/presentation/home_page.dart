import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hanzbthalk/core/widgets/interactive_user_guide.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/core/widgets/home_drawer.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/repos/home_repo.dart';
import 'package:hanzbthalk/features/user/home/widgets/home_tabs_section.dart';
import 'package:hanzbthalk/features/user/home/widgets/place_list_view.dart';
import 'package:hanzbthalk/features/user/home/widgets/category_list.dart';
import 'package:hanzbthalk/features/user/home/widgets/catchy_filter_banner.dart';
import 'package:hanzbthalk/features/user/home/widgets/home_sticky_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'all';
  String selectedTab = 'nearby';

  final GlobalKey _logoKey = GlobalKey();
  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey _bookingsButtonKey = GlobalKey();
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _filterBannerKey = GlobalKey();
  final GlobalKey _categoriesKey = GlobalKey();
  final GlobalKey _tabsKey = GlobalKey();
  final GlobalKey _firstCardKey = GlobalKey();

  bool _showGuide = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeGuide();
  }

  Future<void> _checkFirstTimeGuide() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool shown = prefs.getBool('first_time_guide_shown') ?? false;
      if (!shown) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showGuide = true;
            });
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _finishGuide() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_time_guide_shown', true);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _showGuide = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocProvider<HomeCubit>(
      create: (context) => HomeCubit(HomeRepoImpl(BookingService())),
      child: Scaffold(
        drawer: HomeDrawer(
          onReplayGuide: () {
            setState(() {
              _showGuide = true;
            });
          },
        ),
        body: Stack(
          children: [
            BackGround(h: h, w: w, category: selectedCategory),

            // 1. Scrollable Content (Banner, Categories, Tabs, PlaceListView)
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: w * 0.04,
                  right: w * 0.04,
                  top:
                      MediaQuery.of(context).padding.top +
                      145, // app bar + search bar + margins
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    CatchyFilterBanner(key: _filterBannerKey),
                    const SizedBox(height: 15),
                    CategoryList(
                      key: _categoriesKey,
                      selectedCategory: selectedCategory,
                      onCategoryChanged: (category) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    HomeTabsSection(key: _tabsKey, currentTab: selectedTab),
                    const SizedBox(height: 15),
                    PlaceListView(
                      category: selectedCategory,
                      firstCardKey: _firstCardKey,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Fixed Sticky Top Container (App Bar + Search Bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HomeStickyHeader(
                menuKey: _menuButtonKey,
                logoKey: _logoKey,
                bookingsKey: _bookingsButtonKey,
                searchBarKey: _searchBarKey,
                selectedCategory: selectedCategory,
                selectedTab: selectedTab,
              ),
            ),

            // 3. User Guide
            if (_showGuide)
              InteractiveUserGuide(
                targetKeys: {
                  'logo': _logoKey,
                  'menu': _menuButtonKey,
                  'bookings': _bookingsButtonKey,
                  'search': _searchBarKey,
                  'filters': _filterBannerKey,
                  'categories': _categoriesKey,
                  'tabs': _tabsKey,
                  'firstCard': _firstCardKey,
                },
                onFinish: _finishGuide,
                onSkip: _finishGuide,
              ),
          ],
        ),
      ),
    );
  }
}
