import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/map_filter_bottomsheet.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/widgets/active_filter_banner.dart';
import 'package:hanzbthalk/features/user/home/widgets/inactive_filter_banner.dart';
import 'package:intl/intl.dart';

class CatchyFilterBanner extends StatefulWidget {
  const CatchyFilterBanner({super.key});

  @override
  State<CatchyFilterBanner> createState() => _CatchyFilterBannerState();
}

class _CatchyFilterBannerState extends State<CatchyFilterBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Formats a 24h string like "14:00" to "2 PM".
  String _formatHourShort(String? hour24) {
    if (hour24 == null) return '';
    try {
      int h = int.parse(hour24.split(':')[0]);
      final period = h >= 12 ? 'PM' : 'AM';
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      return '$h12 $period';
    } catch (_) {
      return hour24;
    }
  }

  /// Opens the filter bottom sheet and applies the result to the cubit.
  Future<void> _openFilterSheet(BuildContext context, HomeCubit cubit) async {
    final result = await MapFilterBottomSheet.show(
      context: context,
      initialLocation: cubit.filterLocation,
      initialRadiusKm: cubit.filterRadiusKm,
      initialAddress: cubit.filterLocationAddress,
      initialDate: cubit.filterDate,
      initialStartHour: cubit.filterStartHour,
      initialEndHour: cubit.filterEndHour,
    );

    if (result != null) {
      if (result['clear'] == true) {
        cubit.clearFilters();
      } else {
        cubit.applyMapAndTimeFilters(
          location: result['location'] as LatLng?,
          radiusKm: result['radiusKm'] as double?,
          address: result['address'] as String?,
          date: result['date'] as DateTime?,
          startHour: result['startHour'] as String?,
          endHour: result['endHour'] as String?,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // We listen to the state changes of HomeCubit to rebuild when filters are updated
    final cubit = context.watch<HomeCubit>();
    final hasActiveFilter =
        cubit.filterLocation != null || cubit.filterDate != null;

    // Build a summary string when filter is active
    String activeSummary = '';
    if (hasActiveFilter) {
      final parts = <String>[];
      if (cubit.filterLocationAddress != null) {
        parts.add("📍 ${cubit.filterLocationAddress}");
      }
      if (cubit.filterDate != null) {
        parts.add("📅 ${DateFormat('EEE d/M').format(cubit.filterDate!)}");
      }
      if (cubit.filterStartHour != null && cubit.filterEndHour != null) {
        parts.add(
          "🕐 ${_formatHourShort(cubit.filterStartHour)} → ${_formatHourShort(cubit.filterEndHour)}",
        );
      }
      activeSummary = parts.join('  •  ');
    }

    return GestureDetector(
      onTap: () => _openFilterSheet(context, cubit),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasActiveFilter
                    ? [
                        ColorManager.egyptianEarth.withOpacity(0.15),
                        ColorManager.cardSurface.withOpacity(0.7),
                      ]
                    : [
                        ColorManager.egyptianEarth.withOpacity(0.08),
                        ColorManager.cardSurface.withOpacity(0.5),
                        ColorManager.emeraldGreen.withOpacity(0.08),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: hasActiveFilter
                    ? ColorManager.egyptianEarth.withOpacity(0.8)
                    : ColorManager.egyptianEarth.withOpacity(
                        _pulseAnimation.value * 0.6,
                      ),
                width: 1.5,
              ),
              boxShadow: [
                if (!hasActiveFilter)
                  BoxShadow(
                    color: ColorManager.egyptianEarth.withOpacity(
                      _pulseAnimation.value * 0.12,
                    ),
                    blurRadius: 16,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: hasActiveFilter
                ? ActiveFilterBanner(
                    summary: activeSummary,
                    onClear: () => cubit.clearFilters(),
                  )
                : const InactiveFilterBanner(),
          );
        },
      ),
    );
  }
}
