import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/brand_logo.dart';
import 'package:hanzbthalk/core/widgets/lang_button.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';

class HomeDrawer extends StatelessWidget {
  final VoidCallback? onReplayGuide;

  const HomeDrawer({
    super.key,
    this.onReplayGuide,
  });

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
              color: ColorManager.noirDeVigne,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
              border: Border(
                bottom: BorderSide(
                  color: ColorManager.emeraldGreen,
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: ColorManager.cardSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    size: h * 0.06,
                    color: ColorManager.egyptianEarth,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BrandLogo(
                    fontSize: h * 0.035,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: h * 0.02),

          // القائمة
          _buildDrawerItem(
            context: context,
            icon: Icons.history,
            titleKey: 'myBookings', // ضفت لك اختيار حجوزاتي لأنه أساسي
            onTap: () {
              Navigator.pushNamed(context, Routes.myBookings);
            },
          ),

          const SizedBox(height: 10),

          // Settings-style Language Switcher
          _buildLanguageSettingsItem(context, w, h),

          const SizedBox(height: 10),

          // Replay Guide Setting Item
          _buildDrawerItem(
            context: context,
            icon: Icons.explore_outlined,
            titleKey: 'replayGuide',
            onTap: () {
              Navigator.pop(context); // Close the drawer
              if (onReplayGuide != null) {
                onReplayGuide!();
              }
            },
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
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.authWrapper, (_) => false);
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

  Widget _buildLanguageSettingsItem(BuildContext context, double w, double h) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: ColorManager.wasabi,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr('languageSetting', defaultValue: 'Language / اللغة'),
                    style: TextStyleMangare.headingStyle.copyWith(
                      color: Colors.white,
                      fontSize: h * 0.018,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const LanguageToggleButton(),
        ],
      ),
    );
  }
}
