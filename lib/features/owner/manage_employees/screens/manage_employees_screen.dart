import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_cubit.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_state.dart';
import 'package:hanzbthalk/features/owner/manage_employees/widgets/manage_employees_listview.dart';
import 'package:hanzbthalk/features/owner/manage_employees/widgets/manage_employees_searchbar.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/core/db/permission_service.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';

class ManageEmployeesScreen extends StatelessWidget {
  const ManageEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    final canManageEmployees =
        currentUser != null &&
        PermissionService.can(currentUser, 'manageEmployees');

    if (!canManageEmployees) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            context.tr(
              'manageEmployeesTitle',
              defaultValue: 'Manage Employees',
            ),
          ),
        ),
        body: Center(
          child: Text(
            context.tr('permission_denied', defaultValue: 'Permission Denied'),
          ),
        ),
      );
    }

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    // Retrieve owner's places from the singleton Cubit
    final places = getIt<ManageBookingPlaceCubit>().places;

    return BlocProvider(
      create: (context) =>
          getIt<ManageEmployeesCubit>()..loadCurrentEmployees(),
      child: Scaffold(
        backgroundColor: ColorManager.noirDeVigne,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: ColorManager.wasabi),
          title: Text(
            context.tr(
              'manageEmployeesTitle',
              defaultValue: 'Manage Employees',
            ),
            style: TextStyleMangare.headingStyle.copyWith(
              fontSize: w * 0.06,
              color: ColorManager.wasabi,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: BlocListener<ManageEmployeesCubit, ManageEmployeesState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              SnackBarUtils.showError(context, state.errorMessage!);
              context.read<ManageEmployeesCubit>().clearMessages();
            }
            if (state.successMessage != null) {
              SnackBarUtils.showSuccess(context, state.successMessage!);
              context.read<ManageEmployeesCubit>().clearMessages();
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                BackGround(h: h, w: w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const ManageEmployeesSearchBar(),
                      const SizedBox(height: 20),
                      Expanded(child: ManageEmployeesListView(places: places)),
                    ],
                  ),
                ),
                if (context.watch<ManageEmployeesCubit>().state.isActionLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black45,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ColorManager.wasabi,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
