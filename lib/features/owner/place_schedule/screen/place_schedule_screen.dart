import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_impl.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/logic/schedule_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/logic/schedule_state.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/booking_summary_dialog.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/calendar_strip.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/place_schedule_header.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/schedule_action_bar.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/sub_place_selector.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/widgets/time_slots_list.dart';
// تأكد من استيراد الـ Service لو كنت بتستخدمها هنا
// import 'package:remaking_booking_app_trail2/features/owner/data/owner_service.dart';

class PlaceScheduleScreen extends StatelessWidget {
  final String placeId; // غيرنا دي لـ ID بس عشان نضمن الـ Live Data

  const PlaceScheduleScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      // هنا بننشئ الكوبيت وبنقوله ابدأ راقب المكان ده بالـ ID بتاعه فوراً
      create: (context) => ScheduleCubit(
        FirestoreOwnerService(AuthService()),
        OwnerRepoImpl(FirestoreOwnerService(AuthService())),
      )..startWatchingPlace(placeId),
      child: Scaffold(
        backgroundColor: ColorManager.noirDeVigne,
        body: Stack(
          children: [
            BackGround(h: size.height, w: size.width),
            SafeArea(
              child: BlocConsumer<ScheduleCubit, ScheduleState>(
                listener: (context, state) {
                  // هنا بنراقب لو حصل نجاح في الحجز أو الإلغاء اليدوي
                  if (state.status == ScheduleStatus.actionSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('operation_success')),
                        backgroundColor: ColorManager.emeraldGreen,
                      ),
                    );
                  } else if (state.status == ScheduleStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.tr(state.errorMessage ?? 'error'),
                        ),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // حالة التحميل لأول مرة
                  if (state.status == ScheduleStatus.loading &&
                      state.currentPlace == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorManager.wasabi,
                      ),
                    );
                  }

                  // لو الداتا مجاتش خالص (Error)
                  if (state.currentPlace == null) {
                    return Center(
                      child: Text(
                        context.tr('place_not_found'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final currentPlace = state.currentPlace!;

                  return Column(
                    children: [
                      PlaceScheduleHeader(placeName: currentPlace.name),
                      Expanded(
                        child: _buildScheduleBody(context, currentPlace, state),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleBody(
    BuildContext context,
    PlaceModel currentPlace,
    ScheduleState state,
  ) {
    final scheduleCubit = context.read<ScheduleCubit>();

    return Stack(
      children: [
        Column(
          children: [
            CalendarStrip(
              place: currentPlace,
              selectedDate: state.selectedDate,
              selectedSubPlaceIndex: state.selectedSubPlaceIndex,
              onDateSelected: scheduleCubit.selectDate,
            ),
            SubPlaceSelector(
              count: currentPlace.subPlaces.length,
              selectedIndex: state.selectedSubPlaceIndex,
              onTap: scheduleCubit.selectSubPlace,
            ),
            Expanded(
              child: TimeSlotsList(
                place: currentPlace,
                selectedDate: state.selectedDate,
                subPlaceIndex: state.selectedSubPlaceIndex,
                selectedSlots: state.selectedSlots,
                activeBookingId: state.activeBookingId,
                onSlotTap: (slot, isBooked, _) {
                  scheduleCubit.toggleSlot(slot, isBooked, place: currentPlace);
                },
              ),
            ),
            if (state.hasSelection)
              ScheduleActionBar(
                selectedCount: state.selectedSlots.length,
                isSelectingBooked: state.isSelectingBooked ?? false,
                onClearSelection: scheduleCubit.clearSelection,
                onActionPressed: () =>
                    _openSummaryDialog(context, currentPlace, state),
              ),
          ],
        ),
        // لودينج خفيف يظهر فوق الشاشة وقت تنفيذ الأكشن (حجز/إلغاء)
        if (state.status == ScheduleStatus.loading) const _LoadingOverlay(),
      ],
    );
  }

  void _openSummaryDialog(
    BuildContext context,
    PlaceModel currentPlace,
    ScheduleState state,
  ) {
    final bool isCancellation = state.isSelectingBooked ?? false;
    final scheduleCubit = context.read<ScheduleCubit>();

    BookingSummaryDialog.show(
      context: context,
      place: currentPlace,
      selectedSlots: state.selectedSlots,
      totalPrice: _calculateTotal(currentPlace, state),
      mood: isCancellation ? DialogMood.cancellation : DialogMood.booking,
      onConfirmed: ({required String phone, required double deposit}) {
        if (isCancellation) {
          scheduleCubit.cancelManualBooking(
            placeId: currentPlace.id,
            subPlaceIndex: state.selectedSubPlaceIndex,
            slots: state.selectedSlots,
            bookingDate: state.selectedDate,
          );
        } else {
          scheduleCubit.addManualBooking(
            bookingDate: state.selectedDate,
            userPhone: phone,
            placeId: currentPlace.id,
            subPlaceId:
                state.currentPlace!.subPlaces[state.selectedSubPlaceIndex].id,
            selectedSlots: state.selectedSlots,
            pricePerHour:
                (currentPlace
                        .subPlaces[state.selectedSubPlaceIndex]
                        .pricePerHour)
                    .toDouble(),
            deposit: deposit,
          );
        }
      },
    );
  }

  double _calculateTotal(PlaceModel place, ScheduleState state) {
    final subPlace = place.subPlaces[state.selectedSubPlaceIndex];
    final double price = (subPlace.pricePerHour).toDouble();
    return state.selectedSlots.length * price;
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();
  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: ColoredBox(
        color: Colors.black45,
        child: Center(
          child: CircularProgressIndicator(color: ColorManager.wasabi),
        ),
      ),
    );
  }
}
