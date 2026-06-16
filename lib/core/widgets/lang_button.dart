import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/language/cubit/language_cubit.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, currentLocale) {
        final isEn = currentLocale.languageCode == 'en';

        return GestureDetector(
          onTap: () {
            context.read<LanguageCubit>().changeLanguage(isEn ? 'ar' : 'en');
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ColorManager.wasabi.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ColorManager.wasabi.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language,
                        color: ColorManager.wasabi,
                        size: w * 0.045,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEn
                            ? "AR"
                            : "EN", // بنعرض اللغة اللي هيحول ليها أو الحالية
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: w * 0.035,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
