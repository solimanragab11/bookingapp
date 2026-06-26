import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';

class BookingDeadlineIndicator extends StatelessWidget {
  final DateTime startTime;

  const BookingDeadlineIndicator({super.key, required this.startTime});

  @override
  Widget build(BuildContext context) {
    final difference = startTime.difference(DateTime.now());
    final minutesUntilBooking = difference.inMinutes;

    if (minutesUntilBooking > 360) {
      final hoursLeftForFree = ((minutesUntilBooking - 360) / 60.0)
          .toStringAsFixed(1);
      return _buildIndicator(
        context: context,
        color: Colors.greenAccent,
        text: context.tr(
          'free_cancel_indicator',
          defaultValue:
              'Free cancellation minus 10 EGP admin fee for the next $hoursLeftForFree hours.',
        ),
      );
    } else if (minutesUntilBooking >= 120) {
      return _buildIndicator(
        context: context,
        color: Colors.orangeAccent,
        text: context.tr(
          'penalty_cancel_indicator',
          defaultValue: 'Cancellation penalty of 50% deposit now active.',
        ),
      );
    } else {
      return _buildIndicator(
        context: context,
        color: Colors.redAccent,
        text: context.tr(
          'no_refund_indicator',
          defaultValue:
              'Ineligible for refund (match starts in less than 2 hours).',
        ),
      );
    }
  }

  Widget _buildIndicator({
    required BuildContext context,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
