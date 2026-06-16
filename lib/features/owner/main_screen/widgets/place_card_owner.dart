import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:hanzbthalk/features/owner/place_schedule/screen/place_schedule_screen.dart';

import 'package:hanzbthalk/core/services/permission_service.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';

class PlaceCardOwner extends StatelessWidget {
  final PlaceModel place;

  const PlaceCardOwner({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    final canViewAnalytics = currentUser != null && PermissionService.can(currentUser, 'viewAnalytics');
    final canViewBookings = currentUser != null && PermissionService.can(currentUser, 'viewBookings');

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Slidable(
        key: ValueKey(place.id),
        endActionPane: canViewAnalytics
            ? ActionPane(
                motion: const BehindMotion(),
                extentRatio: 0.55,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      Navigator.pushNamed(
                        context,
                        '/ownerDashboard',
                        arguments: place.id,
                      );
                    },
                    backgroundColor: ColorManager.egyptianEarth,
                    foregroundColor: Colors.white,
                    icon: Icons.trending_up_rounded,
                    label: context.tr('statistics', defaultValue: 'Statistics'),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(24),
                    ),
                  ),
                ],
              )
            : null,
        child: GestureDetector(
          onTap: () {
            if (!canViewBookings) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr('permission_denied', defaultValue: 'Permission Denied')),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            final cubit = context.read<ManageBookingPlaceCubit>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: cubit,
                  child: PlaceScheduleScreen(placeId: place.id),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.cardSurface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ColorManager.emeraldGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlaceImage(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: _buildCardHeader(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceImage(BuildContext context) {
    return SizedBox(
      height: 145,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: place.images.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: place.images[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: ColorManager.noirDeVigne,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorManager.egyptianEarth,
                        ),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: ColorManager.noirDeVigne,
                  child: const Icon(Icons.broken_image, color: Colors.white54),
                ),
              )
            : Container(
                color: ColorManager.noirDeVigne,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.white54,
                ),
              ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: const TextStyle(
                  color: ColorManager.wasabi,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${context.tr(place.type)} • ${place.subPlacesIds.length} ${context.tr('fields')}",
                style: const TextStyle(
                  color: ColorManager.creasedKhaki,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorManager.egyptianEarth.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chevron_right_rounded,
            color: ColorManager.egyptianEarth,
          ),
        ),
      ],
    );
  }
}
