import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/build_info_column.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/build_status_badge.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCardWidget({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final double total = (booking['totalPrice'] ?? 0).toDouble();
    final double paid = (booking['paidAmount'] ?? 0).toDouble();
    final double remaining = total - paid;
    final String orderId = booking['id'] ?? "N/A";

    final placeInfo = booking['placeInfo'] as Map<String, dynamic>?;
    final placeModel = placeInfo != null ? PlaceModel.fromJson(placeInfo) : null;

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
                  : () {
                      Navigator.pushNamed(
                        context,
                        Routes.placeDetails,
                        arguments: placeModel,
                      );
                    },
              splashColor: ColorManager.egyptianEarth.withOpacity(0.15),
              highlightColor: ColorManager.egyptianEarth.withOpacity(0.05),
              child: Ink(
                padding: const EdgeInsets.all(16),
                decoration: _buildCardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, orderId, paid, total),
                    const SizedBox(height: 10),
                    _buildMainInfo(context, placeModel != null),
                    const Divider(color: Colors.white12, height: 24),
                    _buildPaymentRow(context, paid, remaining, total),
                    if (placeModel != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: ColorManager.egyptianEarth.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ColorManager.egyptianEarth.withOpacity(0.4),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr('rebook'),
                                style: const TextStyle(
                                  color: ColorManager.egyptianEarth,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.refresh_rounded,
                                color: ColorManager.egyptianEarth,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

  Widget _buildHeader(
    BuildContext context,
    String orderId,
    double paid,
    double total,
  ) {
    final String displayId = orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "${context.tr('orderIdLabel')}$displayId",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontFamily: 'Roboto',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        BuildStatusBadge(paidAmount: paid, totalPrice: total),
      ],
    );
  }

  Widget _buildMainInfo(BuildContext context, bool hasPlace) {
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.noirDeVigne,
          border: Border.all(
            color: ColorManager.emeraldGreen.withOpacity(0.4),
          ),
        ),
        child: Icon(
          categoryIcon,
          color: ColorManager.egyptianEarth,
          size: 22,
        ),
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
        child: Text(
          "${context.tr(day)} $date\n${booking['timeSlots']?.values?.first?.join(', ') ?? ''}",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
            height: 1.4,
          ),
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

  Widget _buildPaymentRow(
    BuildContext context,
    double paid,
    double remaining,
    double total,
  ) {
    final currency = context.tr('egp');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BuildInfoColumn(
          label: context.tr('paid'),
          amount: "${paid.toStringAsFixed(0)} $currency",
          color: ColorManager.wasabi,
        ),
        BuildInfoColumn(
          label: context.tr('remaining'),
          amount: "${remaining.toStringAsFixed(0)} $currency",
          color: ColorManager.egyptianEarth,
        ),
        BuildInfoColumn(
          label: context.tr('total'),
          amount: "${total.toStringAsFixed(0)} $currency",
          color: Colors.white,
        ),
      ],
    );
  }
}
