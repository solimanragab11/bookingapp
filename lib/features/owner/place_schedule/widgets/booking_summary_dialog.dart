import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';

class BookingSummaryDialog {
  static Future<void> show({
    required BuildContext context,
    required Place place,
    required DateTime selectedDate,
    required int selectedSubPlaceIndex,
    required List<String> selectedSlots,
    required bool isSelectingBooked,
    required VoidCallback onConfirmed,
  }) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final dayKey = DateFormat('EEEE').format(selectedDate).toLowerCase();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorManager.cardSurface,
        title: Text(
          isSelectingBooked ? ctx.tr('cancelBookings') : ctx.tr('newBooking'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${ctx.tr('selectedHours')}: ${selectedSlots.join(', ')}",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (!isSelectingBooked) ...[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: ctx.tr('customerName')),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: ctx.tr('phoneNumber')),
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              ctx.read<ManageBookingPlaceCubit>().updateSlotsBulk(
                placeId: place.id,
                subPlaceIndex: selectedSubPlaceIndex,
                day: dayKey,
                slots: selectedSlots,
                isCanceling: isSelectingBooked,
              );
              Navigator.pop(ctx);
              onConfirmed();
            },
            child: Text(ctx.tr('confirm')),
          ),
        ],
      ),
    );
  }
}
