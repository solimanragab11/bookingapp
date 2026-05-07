import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';

class DateDisplayBanner extends StatelessWidget {
  final DateTimeRange range;
  const DateDisplayBanner({super.key, required this.range});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${context.tr('showing_data_from')}: ${DateFormat('dd MMM').format(range.start)} ${context.tr('to')} ${DateFormat('dd MMM').format(range.end)}",
        style: const TextStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }
}
