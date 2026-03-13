import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart'; // هنستخدم الـ Styles اللي هنا
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_cubit.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Drawer(
      // استخدام خلفية غامقة وكلاسيك تليق بستايل Godfather
      backgroundColor: ColorManager.cardSurface.withOpacity(0.95),
      child: Column(
        children: [
          // Header مطور بستايل الأبلكيشن
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: h * 0.06, bottom: h * 0.03),
            decoration: const BoxDecoration(
              color: ColorManager.wasabi,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50), // انحناء كلاسيك
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    size: h * 0.06,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  context.tr('appName'),
                  style: TextStyleMangare.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: h * 0.035, // Responsive font
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.02),

          // القائمة
          _buildDrawerItem(
            context: context,
            icon: Icons.person_outline,
            titleKey: 'profile',
            onTap: () {
              // Navigator.pushNamed(context, Routes.profile);
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.notifications_none_outlined,
            titleKey: 'notifications',
            onTap: () {
              // Navigator.pushNamed(context, Routes.notifications);
            },
          ),

          _buildDrawerItem(
            context: context,
            icon: Icons.history,
            titleKey: 'myBookings', // ضفت لك اختيار حجوزاتي لأنه أساسي
            onTap: () {},
          ),

          const Spacer(),

          const Divider(color: Colors.white10, indent: 20, endIndent: 20),

          // زر تسجيل الخروج بستايل مميز
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: w * 0.08,
              vertical: 5,
            ),
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              context.tr('logout'),
              style: TextStyleMangare.headingStyle.copyWith(
                color: Colors.redAccent,
                fontSize: h * 0.02,
              ),
            ),
            onTap: () {
              context.read<AuthCubit>().logout();
              Navigator.pushReplacementNamed(context, Routes.authWrapper);
            },
          ),

          SizedBox(height: h * 0.03),
        ],
      ),
    );
  }

  // Widget صغيرة عشان نوحد شكل الـ Items ونقلل الكود
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String titleKey,
    required VoidCallback onTap,
  }) {
    final h = MediaQuery.of(context).size.height;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.08,
      ),
      leading: Icon(icon, color: ColorManager.wasabi, size: 26),
      title: Text(
        context.tr(titleKey),
        style: TextStyleMangare.headingStyle.copyWith(
          color: Colors.white,
          fontSize: h * 0.022,
          fontWeight: FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
