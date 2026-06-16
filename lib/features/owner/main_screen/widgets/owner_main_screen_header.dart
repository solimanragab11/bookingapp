import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/widgets/brand_logo.dart';
import 'package:hanzbthalk/core/widgets/lang_button.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';

import 'package:hanzbthalk/core/services/permission_service.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class OwnerMainScreenHeader extends StatelessWidget {
  const OwnerMainScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final currentUser = context.read<AuthCubit>().currentUser;
    final canManageEmployees = currentUser != null && PermissionService.can(currentUser, 'manageEmployees');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glassmorphic Logout/Back Button
              GestureDetector(
                onTap: () {
                  context.read<AuthCubit>().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.authWrapper, (_) => false);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.redAccent,
                        size: w * 0.055,
                      ),
                    ),
                  ),
                ),
              ),
              if (canManageEmployees) ...[
                const SizedBox(width: 8),
                // Glassmorphic Manage Employees Button
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.manageEmployees);
                  },
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
                          Icons.people_rounded,
                          color: ColorManager.wasabi,
                          size: w * 0.055,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Central Brand Logo
          BrandLogo(
            fontSize: w * 0.06,
            letterSpacing: 1.2,
          ),

          // Glassmorphic Translation Toggle Button
          const LanguageToggleButton(),
        ],
      ),
    );
  }
}
