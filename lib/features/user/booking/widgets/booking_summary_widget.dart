import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class BookingSummaryWidget extends StatelessWidget {
  final Set<String> selectedBookingSlots;

  const BookingSummaryWidget({super.key, required this.selectedBookingSlots});

  String _format(String template, List<dynamic> args) {
    for (var arg in args) {
      template = template.replaceFirst('{}', arg.toString());
    }
    return template;
  }

  @override
  Widget build(BuildContext context) {
    if (selectedBookingSlots.isEmpty) return const SizedBox.shrink();

    Map<String, List<int>> summary = {};
    for (var slotId in selectedBookingSlots) {
      var parts = slotId.split('_');
      // تأكد إن الـ slotId جاي بالشكل ده: "Monday_14:00"
      int hour = int.parse(parts[1].split(':')[0]);
      summary.putIfAbsent(parts[0], () => []).add(hour);
    }

    return Column(
      children: summary.entries.map((entry) {
        String dayName = context.tr(entry.key.toLowerCase());
        List<int> hours = entry.value..sort();
        int count = hours.length;

        bool isConsecutive = true;
        for (int i = 0; i < hours.length - 1; i++) {
          if (hours[i + 1] - hours[i] != 1) {
            isConsecutive = false;
            break;
          }
        }

        String finalMessage = "";
        String hourLabel = (count >= 3 && count <= 10)
            ? context.tr('hour_plural')
            : context.tr('hour_singular');

        if (isConsecutive) {
          finalMessage = _format(context.tr('summary_consecutive'), [
            count,
            hourLabel,
            hours.first,
            hours.last + 1,
            dayName,
          ]);
        } else {
          String header = _format(context.tr('summary_separate'), [
            count,
            dayName,
          ]);
          List<String> slotsDetails = [];
          for (int i = 0; i < hours.length; i++) {
            slotsDetails.add(
              _format(context.tr('slot_prefix'), [
                i + 1,
                hours[i],
                hours[i] + 1,
              ]),
            );
          }
          finalMessage = "$header\n${slotsDetails.join('\n')}";
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: ColorManager.cardSurface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: ColorManager.emeraldGreen.withOpacity(0.25),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: ColorManager.egyptianEarth,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  finalMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
