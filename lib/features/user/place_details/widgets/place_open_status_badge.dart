import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';

class PlaceOpenStatusBadge extends StatelessWidget {
  final String openingTime;
  final String closingTime;
  final double w;

  const PlaceOpenStatusBadge({
    super.key,
    required this.openingTime,
    required this.closingTime,
    required this.w,
  });

  bool _isPlaceOpen(String openStr, String closeStr) {
    try {
      final now = DateTime.now();

      TimeOfDay parseTime(String timeStr) {
        final cleanStr = timeStr.trim().toLowerCase();
        final isPm = cleanStr.contains('pm');
        final isAm = cleanStr.contains('am');
        final numericStr = cleanStr.replaceAll('am', '').replaceAll('pm', '').trim();
        final parts = numericStr.split(':');
        if (parts.length < 2) return const TimeOfDay(hour: 0, minute: 0);

        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (isPm && hour < 12) {
          hour += 12;
        } else if (isAm && hour == 12) {
          hour = 0;
        }

        return TimeOfDay(hour: hour, minute: minute);
      }

      final openTime = parseTime(openStr);
      final closeTime = parseTime(closeStr);

      final currentMinutes = now.hour * 60 + now.minute;
      final openMinutes = openTime.hour * 60 + openTime.minute;
      final closeMinutes = closeTime.hour * 60 + closeTime.minute;

      if (closeMinutes > openMinutes) {
        return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
      } else {
        return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
      }
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _isPlaceOpen(openingTime, closingTime);
    final color = isOpen ? Colors.green : Colors.red;
    final text = isOpen
        ? context.tr('openStatus', defaultValue: 'Open Now')
        : context.tr('closedStatus', defaultValue: 'Closed');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isOpen ? Colors.greenAccent : Colors.redAccent,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
