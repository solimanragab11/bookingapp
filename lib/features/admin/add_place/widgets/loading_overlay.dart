import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_state.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddPlaceCubit, AddPlaceState>(
      builder: (context, state) {
        if (!state.isLoading) return const SizedBox.shrink();

        return Container(
          color: Colors.black87,
          child: const Center(
            child: CircularProgressIndicator(color: ColorManager.wasabi),
          ),
        );
      },
    );
  }
}
