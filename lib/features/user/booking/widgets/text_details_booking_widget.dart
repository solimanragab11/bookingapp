import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';

class TextDetailsBookingWidget extends StatelessWidget {
  final double w, h;
  final PlaceModel place;
  final SubPlace subPlace;
  final Map<String, List<String>> availableDaysWithSlots;
  final String? selectedDay;
  final Function(String?) onDaySelected;

  const TextDetailsBookingWidget({
    super.key,
    required this.w,
    required this.h,
    required this.place,
    required this.subPlace,
    required this.availableDaysWithSlots,
    required this.onDaySelected,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: h * 0.01),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(w * 0.05),
            decoration: BoxDecoration(
              color: ColorManager.cardSurface.withOpacity(0.2), // نفس الشفافية
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. العنوان (اسم المكان والفرع)
                Text(
                  '${context.tr('placeColon')} ${place.name}',
                  style: TextStyle(
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.wasabi, // لون الوسابي المميز
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subPlace.id, // اسم القسم أو الملعب الفرعي
                  style: TextStyle(
                    fontSize: w * 0.045,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                  ),
                ),

                // 2. تفاصيل الملعب (أيقونات شيك)
                _buildInfoRow(
                  Icons.groups_outlined,
                  '${context.tr('playersColon')} ${subPlace.playersNumber}',
                  Colors.blueAccent,
                  w,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.payments_outlined,
                  '${context.tr('pricePerHourColon')} ${subPlace.pricePerHour.toStringAsFixed(2)} ${context.tr('le')}',
                  ColorManager.creasedKhaki,
                  w,
                  isBold: true,
                ),

                const SizedBox(height: 20),

                // 3. اختيار اليوم (Dropdown متناسق مع الزجاج)
                if (availableDaysWithSlots.isNotEmpty) ...[
                  Text(
                    context.tr('selectDay'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: w * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildGlassDropdown(context),
                ] else
                  _buildUnavailableMessage(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ميثود بناء الصفوف بنفس ستايلك القديم
  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color iconColor,
    double w, {
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: w * 0.055),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: w * 0.04,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // دروب داون "زجاجي"
  Widget _buildGlassDropdown(BuildContext context) {
    // 1. استخراج الأيام وترتيبها بناءً على التاريخ الفعلي
    final sortedDays = availableDaysWithSlots.keys.toList()
      ..sort((a, b) {
        // بنجيب التاريخ من الـ String (مثلاً بنحول 18/03 لتاريخ حقيقي)
        DateTime dateA = _extractDate(a);
        DateTime dateB = _extractDate(b);
        return dateA.compareTo(dateB);
      });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedDay,
          isExpanded: true,
          dropdownColor: ColorManager.cardSurface.withOpacity(0.95),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ColorManager.wasabi,
          ),
          style: TextStyleMangare.headingStyle.copyWith(
            // استخدمنا الـ font بتاعنا هنا
            color: Colors.white,
            fontSize: 16,
          ),
          items: sortedDays.map((day) {
            return DropdownMenuItem(
              value: day,
              child: Text(day), // بنعرض الـ String زي ما هو (wednesday 18/03)
            );
          }).toList(),
          onChanged: onDaySelected,
        ),
      ),
    );
  }

  // دالة سحرية عشان تطلع التاريخ من وسط الكلام وترتب بيه
  DateTime _extractDate(String dayString) {
    try {
      // بياخد الجزء اللي فيه التاريخ (مثلاً 18/03)
      List<String> parts = dayString.split(' ');
      if (parts.length < 2) return DateTime.now();

      List<String> dateParts = parts[1].split('/');
      int day = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);

      // بنفترض إن السنة هي السنة الحالية
      return DateTime(DateTime.now().year, month, day);
    } catch (e) {
      return DateTime.now(); // لو حصل أي غلط يرجعه للآخر
    }
  }

  Widget _buildUnavailableMessage(BuildContext context) {
    return Center(
      child: Text(
        context.tr('unavailable'),
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
