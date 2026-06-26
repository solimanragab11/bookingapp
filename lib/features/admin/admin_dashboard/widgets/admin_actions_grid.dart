import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/admin/offer/offer_list/screen/offer_list_screen.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';

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
          isLogout: false,
        ),
        _ActionCard(
          title: context.tr("Mange Places"),
          icon: Icons.precision_manufacturing_rounded,
          onTap: () {
            Navigator.pushNamed(context, Routes.adminHome);
          },
          isLogout: false,
        ),
        _ActionCard(
          title: context.tr("Manage Auth"),
          icon: Icons.admin_panel_settings,
          onTap: () {
            Navigator.pushNamed(context, Routes.adminMangeAuth);
          },
          isLogout: false,
        ),
        _ActionCard(
          title: context.tr("Promotions"),
          icon: Icons.campaign_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OffersListPage()),
            );
          },
          isLogout: false,
        ),
        _ActionCard(
          title: context.tr("Refund Requests", defaultValue: "Refund Requests"),
          icon: Icons.monetization_on_outlined,
          onTap: () {
            Navigator.pushNamed(context, Routes.refundRequests);
          },
          isLogout: false,
        ),
        _ActionCard(
          title: context.tr("logout"),
          icon: Icons.logout,
          onTap: () {
            context.read<AuthCubit>().logout();
            Navigator.of(context).pushNamedAndRemoveUntil(Routes.authWrapper, (_) => false);
          },
          isLogout: true,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLogout;
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isLogout,
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
              colors: isLogout
                  ? [Colors.red, Colors.red]
                  : [ColorManager.wasabi.withOpacity(0.15), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: ColorManager.wasabi.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.white : ColorManager.wasabi,
                size: 36,
              ),
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
