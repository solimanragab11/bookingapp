import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/loading_overlay.dart';
import 'package:hanzbthalk/features/admin/mange_auth/logic/manage_auth_cubit.dart';
import 'package:hanzbthalk/features/admin/mange_auth/logic/mange_auth_states.dart';
import 'user_auth_card.dart'; // استدعاء كارت اليوزر اللي عملناه فوق

class ManageAuthListView extends StatelessWidget {
  final double width;
  const ManageAuthListView({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageAuthCubit, ManageAuthState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: ColorManager.wasabi),
          );
        }

        if (state.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_search_rounded,
                  size: width * 0.18,
                  color: ColorManager.wasabi.withOpacity(0.4),
                ),
                const SizedBox(height: 10),
                Text(
                  'Type phone number to start search',
                  style: TextStyle(
                    color: ColorManager.egyptianEarth.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                if (state.isLoading == false) {
                  final user = state.users[index];
                  return UserAuthCard(
                    user: user,
                    isActionLoading: state.isActionLoading,
                    onRoleChanged: (newRole) {
                      if (newRole != null && newRole != user.userRole) {
                        context.read<ManageAuthCubit>().updateUserRole(
                          user.id,
                          newRole,
                        );
                      }
                    },
                  );
                }
                return LoadingOverlay();
              },
            ),
            if (state.isActionLoading)
              Container(
                color: Colors.white12,
                child: Center(
                  child: CircularProgressIndicator(color: ColorManager.wasabi),
                ),
              ),
          ],
        );
      },
    );
  }
}
