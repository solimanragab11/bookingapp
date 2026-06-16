import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(DateTimeRange) onDatePicked;
  const DashboardAppBar({super.key, required this.onDatePicked});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(context.tr('business_dashboard')),
      titleTextStyle: TextStyleMangare.headingStyle.copyWith(
        color: ColorManager.wasabi,
        fontSize: 24,
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_month, color: ColorManager.wasabi),
          onPressed: () async {
            // 👈 الحركة دي هي الحل: بنحفظ الـ context الحالي في متغير
            // عشان الـ async/await ميتوهش الـ Provider البحث عنه لاحقاً

            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
              builder: (context, child) => _buildPickerTheme(context, child!),
            );

            // نستخدم navigatorContext المضمون إنه تحت الـ Cubit
            if (picked != null) {
              onDatePicked(picked);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPickerTheme(BuildContext context, Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: ColorManager.wasabi,
          onPrimary:
              ColorManager.noirDeVigne, // تعديل عشان الكلام يبان فوق الأخضر
          surface: ColorManager.cardSurface,
          onSurface: ColorManager.creasedKhaki,
        ),
        dialogBackgroundColor: ColorManager.noirDeVigne,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: ColorManager.wasabi),
        ),
      ),
      child: child,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
