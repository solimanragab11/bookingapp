import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class AdminActionsGrid extends StatelessWidget {
  final bool isTablet;
  const AdminActionsGrid({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.0,
      children: [
        _ActionCard(
          title: context.tr("Add Place"),
          icon: Icons.add_business_rounded,
          onTap: () {
            Navigator.pushNamed(context, Routes.addPlace);
          },
        ),
        _ActionCard(
          title: context.tr("Delete Place"),
          icon: Icons.delete_forever,
          onTap: () {},
        ),
        _ActionCard(
          title: context.tr("Manage Auth"),
          icon: Icons.admin_panel_settings,
          onTap: () {},
        ),
        _ActionCard(
          title: context.tr("Promotions"),
          icon: Icons.campaign_rounded,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorManager.wasabi.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: ColorManager.wasabi.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ColorManager.wasabi, size: 36),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
