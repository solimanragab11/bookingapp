import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_cubit.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_state.dart';
import 'package:hanzbthalk/features/owner/manage_employees/widgets/edit_employee_dialog.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/core/db/permission_service.dart';

class ManageEmployeesListView extends StatelessWidget {
  final List<PlaceModel> places;
  const ManageEmployeesListView({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageEmployeesCubit, ManageEmployeesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: ColorManager.wasabi),
          );
        }

        final showSearch = state.searchResults.isNotEmpty;
        final list = state.employees;

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            // Search Results Section
            if (showSearch) ...[
              Text(
                context.tr('searchResultsTitle', defaultValue: 'Search Result'),
                style: const TextStyle(
                  color: ColorManager.creasedKhaki,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...state.searchResults.map(
                (user) => _buildUserCard(context, user, isSearchResult: true),
              ),
              const SizedBox(height: 24),
            ],

            // Current Employees Section
            Text(
              context.tr(
                'currentEmployeesTitle',
                defaultValue: 'Current Employees',
              ),
              style: const TextStyle(
                color: ColorManager.creasedKhaki,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    context.tr(
                      'noEmployeesFound',
                      defaultValue: 'No employees added yet.',
                    ),
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              )
            else
              ...list.map(
                (emp) => _buildUserCard(context, emp, isSearchResult: false),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    UserModel user, {
    required bool isSearchResult,
  }) {
    final cubit = context.read<ManageEmployeesCubit>();
    final isEmp = user.userRole == 'employee';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSearchResult
              ? ColorManager.wasabi.withOpacity(0.5)
              : ColorManager.emeraldGreen.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ColorManager.egyptianEarth.withOpacity(0.15),
            child: const Icon(
              Icons.person_rounded,
              color: ColorManager.egyptianEarth,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                if (isEmp) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.wasabi.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${user.assignedPlaceIds.length} ${context.tr('assignedPlaces', defaultValue: 'Places')}',
                      style: const TextStyle(
                        color: ColorManager.wasabi,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final currentUser = context.read<AuthCubit>().currentUser;
              final canManageEmployees =
                  currentUser != null &&
                  PermissionService.can(currentUser, 'manageEmployees');
              if (canManageEmployees) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSearchResult && !isEmp
                        ? ColorManager.wasabi
                        : ColorManager.egyptianEarth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EditEmployeeDialog(
                        user: user,
                        places: places,
                        onSave:
                            ({
                              required assignedPlaceIds,
                              required permissions,
                            }) {
                              cubit.saveEmployee(
                                employeeId: user.id,
                                assignedPlaceIds: assignedPlaceIds,
                                permissions: permissions,
                              );
                            },
                        onDelete: () {
                          cubit.removeEmployee(user.id);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  child: Text(
                    isEmp
                        ? context.tr('edit', defaultValue: 'Edit')
                        : context.tr('add', defaultValue: 'Add'),
                    style: TextStyle(
                      color: isSearchResult && !isEmp
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
