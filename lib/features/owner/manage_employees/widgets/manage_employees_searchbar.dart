import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_cubit.dart';

class ManageEmployeesSearchBar extends StatelessWidget {
  const ManageEmployeesSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.emeraldGreen.withOpacity(0.2)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.phone,
        onChanged: (value) {
          context.read<ManageEmployeesCubit>().searchUserByPhone(value.trim());
        },
        decoration: InputDecoration(
          hintText: context.tr('searchByPhoneHint', defaultValue: 'Enter phone number (e.g. 01xxxxxxxxx)'),
          hintStyle: TextStyle(
            color: Colors.white54,
            fontSize: w * 0.038,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: ColorManager.wasabi),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
