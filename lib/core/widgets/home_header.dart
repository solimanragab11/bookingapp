import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/brand_logo.dart';
import 'package:hanzbthalk/core/routes/routes.dart';

class HomeHeader extends StatelessWidget {
  final Key? menuKey;
  final Key? logoKey;
  final Key? bookingsKey;

  const HomeHeader({
    super.key,
    this.menuKey,
    this.logoKey,
    this.bookingsKey,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // فتح الـ Drawer عند الضغط على أيقونة المنيو (بديل للأيقونات الكتيرة)
          IconButton(
            key: menuKey,
            icon: Icon(
              Icons.menu_rounded,
              color: ColorManager.wasabi,
              size: w * 0.08,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),

          BrandLogo(
            key: logoKey,
            fontSize: w * 0.065,
            letterSpacing: 1.2,
          ),

          // زرار حجوزاتي الزجاجي بدلاً من اللغة
          GestureDetector(
            key: bookingsKey,
            onTap: () {
              Navigator.pushNamed(context, Routes.myBookings);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorManager.wasabi.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorManager.wasabi.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: ColorManager.wasabi,
                      size: w * 0.055,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
