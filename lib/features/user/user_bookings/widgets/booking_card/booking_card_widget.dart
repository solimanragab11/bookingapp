import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_action_buttons.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_card_header.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_deadline_indicator.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_main_info.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_dispute_section.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/cash_pin_display_widget.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_time_helper.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCardWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final double total = (booking['totalPrice'] ?? 0).toDouble();
    final double paid = (booking['paidAmount'] ?? 0).toDouble();
    final double remaining = total - paid;
    final String orderId = booking['id'] ?? "N/A";
    final String status = booking['status'] ?? "N/A";
    final bool isCash = booking['isCash'] ?? false;
    final bool isCashSettled = booking['isCashSettled'] ?? false;
    final String? cashPin = booking['cashPin'];
    final bool showCashPin = isCash && !isCashSettled && remaining > 0 && cashPin != null && cashPin.isNotEmpty;

    final placeInfo = booking['placeInfo'] as Map<String, dynamic>?;
    final placeModel = placeInfo != null
        ? PlaceModel.fromJson(placeInfo)
        : null;

    final startTime = BookingTimeHelper.getBookingStartTime(booking);
    final isFutureBooking =
        startTime != null && startTime.isAfter(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: placeModel == null
                  ? null
                  : () => Navigator.pushNamed(
                      context,
                      Routes.placeDetails,
                      arguments: placeModel,
                    ),
              splashColor: ColorManager.egyptianEarth.withOpacity(0.15),
              highlightColor: ColorManager.egyptianEarth.withOpacity(0.05),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: _buildCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookingCardHeader(
                      orderId: orderId,
                      status: status,
                    ),
                    const SizedBox(height: 10),
                    BookingMainInfo(
                      booking: booking,
                      hasPlace: placeModel != null,
                    ),

                    if (showCashPin) ...[
                      const SizedBox(height: 12),
                      CashPinDisplayWidget(cashPin: cashPin),
                    ],

                    if (status == 'pending_no_show') ...[
                      BookingDisputeSection(booking: booking),
                      const SizedBox(height: 12),
                    ],

                    if (isFutureBooking)
                      BookingDeadlineIndicator(startTime: startTime),

                    const SizedBox(height: 12),

                    if (startTime != null)
                      BookingActionButtons(
                        booking: booking,
                        placeModel: placeModel,
                        startTime: startTime,
                        isFutureBooking: isFutureBooking,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: ColorManager.cardSurface.withOpacity(0.35),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: ColorManager.emeraldGreen.withOpacity(0.25),
        width: 1.0,
      ),
    );
  }
}
