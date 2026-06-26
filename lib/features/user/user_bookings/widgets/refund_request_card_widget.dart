import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/build_info_column.dart';

class RefundRequestCardWidget extends StatelessWidget {
  final Map<String, dynamic> request;

  const RefundRequestCardWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final String requestId = request['id'] ?? "N/A";
    final double originalPaid = (request['amountPaidOnline'] ?? 0).toDouble();
    final double expectedRefund = (request['expectedRefund'] ?? 0).toDouble();
    final String status = request['status'] ?? "pending";

    final placeInfo = request['placeInfo'] as Map<String, dynamic>?;
    final placeModel = placeInfo != null ? PlaceModel.fromJson(placeInfo) : null;

    final String placeName = placeModel?.name ?? "Court";
    final subPlaceInfo = request['subPlaceInfo'] as Map<String, dynamic>?;
    final String subPlaceName = subPlaceInfo != null ? (subPlaceInfo['name'] ?? "") : "";

    final requestDate = _getRequestDate(request);
    final String formattedDate = requestDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(requestDate)
        : "N/A";

    final slotsInfo = _formatSlots(request);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.cardSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ColorManager.cardSurface.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Request ID & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "#$requestId",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(context, status),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Place name & Sub-place details
                  Row(
                    children: [
                      const Icon(
                        Icons.sports_soccer_rounded,
                        color: ColorManager.wasabi,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subPlaceName.isNotEmpty ? "$placeName - $subPlaceName" : placeName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Slots Details
                  if (slotsInfo.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: ColorManager.creasedKhaki,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            slotsInfo,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Request Date
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white24,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${context.tr('requested_at')}: $formattedDate",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),

                  // Refund Amounts Info Columns
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BuildInfoColumn(
                        label: context.tr('original_paid'),
                        amount: "${originalPaid.toStringAsFixed(0)} EGP",
                        color: Colors.white60,
                      ),
                      BuildInfoColumn(
                        label: context.tr('expected_refund'),
                        amount: "${expectedRefund.toStringAsFixed(0)} EGP",
                        color: ColorManager.wasabi,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color badgeColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'approved':
        badgeColor = ColorManager.emeraldGreen;
        statusText = context.tr('refund_status_approved');
        break;
      case 'rejected':
        badgeColor = Colors.redAccent;
        statusText = context.tr('refund_status_rejected');
        break;
      case 'pending':
      default:
        badgeColor = Colors.orangeAccent;
        statusText = context.tr('refund_status_pending');
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.5),
          width: 1.0,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  DateTime? _getRequestDate(Map<String, dynamic> req) {
    try {
      final dynamic created = req['createdAt'];
      if (created is Timestamp) {
        return created.toDate();
      } else if (created is DateTime) {
        return created;
      }
    } catch (_) {}
    return null;
  }

  String _formatSlots(Map<String, dynamic> req) {
    try {
      final Map<String, dynamic>? timeSlots = req['timeSlots'] as Map<String, dynamic>?;
      if (timeSlots == null || timeSlots.isEmpty) return "";

      final String fullDay = timeSlots.keys.first;
      final List<dynamic> slots = timeSlots.values.first as List<dynamic>;

      final String datePart = fullDay.contains(' ') ? fullDay.split(' ').last : fullDay;

      // Group consecutive hours or show them all formatted nicely
      List<String> formatted = slots.map((s) => s.toString()).toList();
      return "$datePart | ${formatted.join(', ')}";
    } catch (_) {}
    return "";
  }
}
