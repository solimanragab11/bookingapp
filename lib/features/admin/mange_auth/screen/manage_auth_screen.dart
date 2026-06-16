import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/admin/mange_auth/logic/manage_auth_cubit.dart';
import 'package:hanzbthalk/features/admin/mange_auth/logic/mange_auth_states.dart';
import 'package:hanzbthalk/features/admin/mange_auth/widgets/mang_auth_searchbar.dart';
import 'package:hanzbthalk/features/admin/mange_auth/widgets/mange_auth_listview.dart';

class ManageAuthScreen extends StatelessWidget {
  const ManageAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorManager.wasabi),
        title: Text(
          context.tr('manageAuthTitle'),
          style: TextStyleMangare.headingStyle.copyWith(
            fontSize: w * 0.06,
            color: ColorManager.wasabi,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: BlocListener<ManageAuthCubit, ManageAuthState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
              ),
            );
            context.read<ManageAuthCubit>().clearMessages();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: ColorManager.wasabi,
              ),
            );
            context.read<ManageAuthCubit>().clearMessages();
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
                    const ManageAuthSearchBar(), // 🔍 شريط البحث المقسم
                    const SizedBox(height: 20),
                    Expanded(
                      child: ManageAuthListView(
                        width: w,
                      ), // 📜 اللستة والنتائج المقسمة
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
