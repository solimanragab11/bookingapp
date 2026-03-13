import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_states.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/logic/schedule_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/logic/schedule_state.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/calendar_strip.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/schedule_action_bar.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/time_slots_list.dart';

class PlaceScheduleScreen extends StatelessWidget {
  final Place place;
  const PlaceScheduleScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => ScheduleCubit(),
      child: Scaffold(
        backgroundColor: ColorManager.noirDeVigne,
        body: Stack(
          children: [
            BackGround(h: size.height, w: size.width),
            SafeArea(
              child:
                  BlocBuilder<ManageBookingPlaceCubit, ManageBookingPlaceState>(
                    builder: (context, state) {
                      final currentPlace = (state is ManagePlaceLoaded)
                          ? state.places.firstWhere(
                              (p) => p.id == place.id,
                              orElse: () => place,
                            )
                          : place;

                      return BlocBuilder<ScheduleCubit, ScheduleState>(
                        builder: (context, scheduleState) {
                          return Column(
                            children: [
                              _buildHeader(context),
                              CalendarStrip(
                                place: currentPlace,
                                selectedDate: scheduleState.selectedDate,
                                selectedSubPlaceIndex:
                                    scheduleState.selectedSubPlaceIndex,
                                onDateSelected: (date) => context
                                    .read<ScheduleCubit>()
                                    .selectDate(date),
                              ),
                              _buildSubPlaceSelector(
                                context,
                                currentPlace.subPlaces.length,
                                scheduleState.selectedSubPlaceIndex,
                              ),
                              Expanded(
                                child: TimeSlotsList(
                                  place: currentPlace,
                                  selectedDate: scheduleState.selectedDate,
                                  subPlaceIndex:
                                      scheduleState.selectedSubPlaceIndex,
                                  selectedSlots: scheduleState.selectedSlots,
                                  onSlotTap: (slot, isBooked) => context
                                      .read<ScheduleCubit>()
                                      .toggleSlot(slot, isBooked),
                                ),
                              ),
                              if (scheduleState.hasSelection &&
                                  scheduleState.isSelectingBooked != null)
                                ScheduleActionBar(
                                  place: currentPlace,
                                  selectedCount:
                                      scheduleState.selectedSlots.length,
                                  isSelectingBooked:
                                      scheduleState.isSelectingBooked!,
                                  selectedDate: scheduleState.selectedDate,
                                  selectedSubPlaceIndex:
                                      scheduleState.selectedSubPlaceIndex,
                                  selectedSlots: scheduleState.selectedSlots,
                                  onClearSelection: () => context
                                      .read<ScheduleCubit>()
                                      .clearSelection(),
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: ColorManager.wasabi),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: const TextStyle(
                    color: ColorManager.wasabi,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  "إدارة الحجوزات والملاعب",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- اختيار الملعب (Sub-place) ---
  Widget _buildSubPlaceSelector(
    BuildContext context,
    int subPlacesCount,
    int selectedIndex,
  ) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subPlacesCount,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => context.read<ScheduleCubit>().selectSubPlace(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorManager.egyptianEarth
                    : ColorManager.emeraldGreen,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white24,
                ),
              ),
              child: Text(
                "ملعب ${index + 1}",
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
