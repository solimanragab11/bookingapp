import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // 👈 ضيف دي
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/screen/place_schedule_screen.dart';
// استورد شاشة الـ Dashboard هنا
// import 'package:remaking_booking_app_trail2/features/owner/dashboard/screen/owner_dashboard_screen.dart';

class PlaceCard extends StatelessWidget {
  final PlaceModel place;

  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Slidable(
        key: ValueKey(place.id),
        // الأكشن اللي بيظهر لما نسحب شمال (من اليمين لليسار)
        endActionPane: ActionPane(
          motion: const BehindMotion(), // شكل الحركة (ممكن تجرب ScrollMotion)
          extentRatio: 0.25, // حجم الزرار اللي هيظهر
          children: [
            SlidableAction(
              onPressed: (context) {
                Navigator.pushNamed(
                  context,
                  '/ownerDashboard',
                  arguments: place.id, // بنبعت الـ ID هنا
                );
              },
              backgroundColor: ColorManager.creasedKhaki,
              foregroundColor: Colors.white,
              icon: Icons.dashboard_customize_outlined,
              label: 'الإحصائيات',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(24),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
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
            // شيلنا الـ margin bottom من هنا عشان الـ Slidable يشتغل صح
            decoration: BoxDecoration(
              color: ColorManager.cardSurface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ColorManager.emeraldGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                _buildPlaceImage(),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildCardHeader(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceImage() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        image: DecorationImage(
          image: NetworkImage(
            place.images.isNotEmpty
                ? place.images[0]
                : 'https://via.placeholder.com/400x200',
          ),
          fit: BoxFit.cover,
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
              Center(
                child: Text(
                  place.name,
                  style: const TextStyle(
                    color: ColorManager.wasabi,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Center(
                child: Text(
                  "${place.type} • ${place.subPlaces.length} ملاعب",
                  style: const TextStyle(
                    color: ColorManager.creasedKhaki,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),

        // زر الإعدادات
      ],
    );
  }
}
