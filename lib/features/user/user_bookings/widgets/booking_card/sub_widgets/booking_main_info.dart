import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class BookingMainInfo extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool hasPlace;

  const BookingMainInfo({
    super.key,
    required this.booking,
    required this.hasPlace,
  });

  @override
  Widget build(BuildContext context) {
    final placeInfo = booking['placeInfo'] as Map<String, dynamic>?;
    final subPlaceInfo = booking['subPlaceInfo'] as Map<String, dynamic>?;
    final rawSubPlaceId = subPlaceInfo?['id'] ?? booking['subPlaceId'] ?? '';

    String subPlaceName = rawSubPlaceId;
    if (rawSubPlaceId.contains('_')) {
      final parts = rawSubPlaceId.split('_');
      if (parts.length > 1) {
        final rawName = parts.sublist(1).join(' ').trim();
        subPlaceName = rawName.replaceAllMapped(RegExp(r'(\D+)(\d+)'), (match) {
          return '${match.group(1)} ${match.group(2)}';
        }).toUpperCase();
      }
    } else {
      subPlaceName = rawSubPlaceId.toUpperCase();
    }

    final category = placeInfo?['category'] as String? ?? 'general';
    final String fullDay = booking['timeSlots']?.keys?.first ?? "";
    String day = fullDay.split(' ').first.toLowerCase();
    String date = fullDay.contains(' ') ? fullDay.split(' ').last : "";

    IconData categoryIcon;
    switch (category.toLowerCase()) {
      case 'football':
        categoryIcon = Icons.sports_soccer;
        break;
      case 'padel':
        categoryIcon = Icons.sports_tennis;
        break;
      case 'playstation':
        categoryIcon = Icons.sports_esports;
        break;
      case 'cafe':
        categoryIcon = Icons.coffee;
        break;
      default:
        categoryIcon = Icons.grid_view_rounded;
    }

    final double total = (booking['totalPrice'] ?? 0).toDouble();
    final double paid = (booking['paidAmount'] ?? 0).toDouble();
    final double remaining = total - paid;

    final String paymentText;
    final Color paymentColor;
    if (remaining <= 0) {
      paymentText = "${context.tr('total_label')}: ${total.toStringAsFixed(0)} EGP (${context.tr('fully_paid_label')})";
      paymentColor = ColorManager.wasabi;
    } else if (paid > 0) {
      paymentText = "${context.tr('total_label')}: ${total.toStringAsFixed(0)} EGP | ${context.tr('paid_label')}: ${paid.toStringAsFixed(0)} EGP | ${context.tr('remaining_label')}: ${remaining.toStringAsFixed(0)} EGP";
      paymentColor = ColorManager.egyptianEarth;
    } else {
      paymentText = "${context.tr('total_label')}: ${total.toStringAsFixed(0)} EGP (${context.tr('unpaid_label')})";
      paymentColor = ColorManager.egyptianEarth;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.noirDeVigne,
          border: Border.all(color: ColorManager.emeraldGreen.withOpacity(0.4)),
        ),
        child: Icon(categoryIcon, color: ColorManager.egyptianEarth, size: 22),
      ),
      title: Text(
        "${placeInfo?['name'] ?? context.tr('placePlaceholder')} - $subPlaceName",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${context.tr(day)} $date • ${booking['timeSlots']?.values?.first?.join(', ') ?? ''}",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              paymentText,
              style: TextStyle(
                color: paymentColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      trailing: hasPlace
          ? Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new
                  : Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.4),
              size: 14,
            )
          : null,
    );
  }
}
