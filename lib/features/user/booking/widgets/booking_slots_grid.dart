import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class BookingSlotsGrid extends StatelessWidget {
  final List<String> slots;
  final String selectedDay;
  final Set<String> selectedBookingSlots;
  final Map<String, List<String>> bookedTimeSlots;
  final Function(String slotId) onSlotToggled;
  final String Function(String) formatTimeSlot;

  const BookingSlotsGrid({
    super.key,
    required this.slots,
    required this.selectedDay,
    required this.selectedBookingSlots,
    required this.bookedTimeSlots,
    required this.onSlotToggled,
    required this.formatTimeSlot,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: ColorManager.creasedKhaki.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grid الحجز
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.1, // ظبطنا النسبة عشان الـ AM/PM تظهر مرتاحة
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final slot = slots[index];
              final slotId = '${selectedDay}_$slot';
              final isBooked =
                  bookedTimeSlots[selectedDay]?.contains(slot) ?? false;
              final isSelected = selectedBookingSlots.contains(slotId);

              return Opacity(
                opacity: isBooked ? 0.4 : 1.0,
                child: ChoiceChip(
                  // 1. شيلنا الـ padding الافتراضي عشان النص يتسنتر صح
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.zero,

                  label: Container(
                    constraints:
                        const BoxConstraints(), // يخلي الـ container ياخد مساحة الـ chip كلها
                    alignment: Alignment.center, // سنتر يا برنس!
                    child: Text(
                      formatTimeSlot(slot),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.03,
                        color: isSelected
                            ? ColorManager.noirDeVigne
                            : (isBooked
                                  ? Colors.white24
                                  : ColorManager.creasedKhaki),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: isBooked ? null : (val) => onSlotToggled(slotId),
                  selectedColor: ColorManager.wasabi,
                  backgroundColor: ColorManager.noirDeVigne.withOpacity(0.6),
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected
                        ? ColorManager.wasabi
                        : ColorManager.creasedKhaki.withOpacity(0.2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
