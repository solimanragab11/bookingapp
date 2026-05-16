import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/admin/mange_auth/logic/manage_auth_cubit.dart';

class ManageAuthSearchBar extends StatelessWidget {
  const ManageAuthSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        context.read<ManageAuthCubit>().searchUsersByPhone(value.trim());
      },
      keyboardType: TextInputType.phone,
      cursorColor: ColorManager.wasabi,
      decoration: InputDecoration(
        hintText: 'Search owner by phone...',
        hintStyle: TextStyle(
          color: ColorManager.wasabi.withOpacity(0.6),
          fontSize: 14,
        ),
        prefixIcon: Icon(Icons.search, color: ColorManager.wasabi),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: ColorManager.creasedKhaki.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: ColorManager.wasabi, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: ColorManager.creasedKhaki.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
