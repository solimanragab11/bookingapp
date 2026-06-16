import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_cubit.dart';

// دالة ثابتة تظهر الديالوج
void showSuccessDialog(BuildContext context) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.bottomSlide,
    title: context.tr('successTitle'),
    desc: context.tr('successMessage'),
    btnOkText: context.tr('ok'),
    btnOkColor: ColorManager.wasabi,
    btnOkOnPress: () {
      context.read<AddPlaceCubit>().reset();
      // مش محتاج Navigator.pop هنا لأن الديالوج بيقفل نفسه لما تدوس OK
    },
  ).show();
}
