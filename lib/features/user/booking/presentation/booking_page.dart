import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_states.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/helpers/booking_helper.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/booking_header_image.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/booking_slots_grid.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/booking_summary_widget.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/flexible_payment_input.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/payment_summary_section.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/text_details_booking_widget.dart';

class BookingPage extends StatelessWidget with BookingHelper {
  final Place place;
  final SubPlace subPlace;

  const BookingPage({super.key, required this.place, required this.subPlace});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) =>
          BookingCubit(BookingService())
            ..initializeBooking(place: place, subPlace: subPlace),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('confirmBooking')),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: ColorManager.wasabi,
          elevation: 0,
        ),
        body: Stack(
          children: [
            BackGround(h: h, w: w),
            BlocConsumer<BookingCubit, BookingState>(
              listener: _bookingListener,
              builder: (context, state) {
                final cubit = context.read<BookingCubit>();

                // Get the data from the current state or the last valid state
                BookingDataState? currentState;
                if (state is BookingDataState) {
                  currentState = state;
                } else if (state is BookingLoading ||
                    state is BookingSlotsUnavailable) {
                  final lastState = cubit.state;
                  if (lastState is BookingDataState) currentState = lastState;
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.04,
                    vertical: h * 0.02,
                  ),
                  child: Column(
                    children: [
                      BookingHeaderImage(
                        imageUrl: subPlace.imageUrl,
                        height: h * 0.22,
                      ),
                      const SizedBox(height: 20),
                      if (currentState != null) ...[
                        TextDetailsBookingWidget(
                          w: w,
                          h: h,
                          place: place,
                          subPlace: subPlace,
                          availableDaysWithSlots: subPlace.freeTimeSlots,
                          selectedDay: currentState.selectedDay,
                          onDaySelected: (day) => cubit.selectDay(day!),
                        ),
                        const SizedBox(height: 25),
                        BookingSlotsGrid(
                          slots:
                              subPlace.freeTimeSlots[currentState
                                  .selectedDay] ??
                              [],
                          selectedDay: currentState.selectedDay!,
                          selectedBookingSlots:
                              currentState.selectedBookingSlots,
                          bookedTimeSlots: subPlace.bookedTimeSlots,
                          onSlotToggled: (id) => cubit.toggleTimeSlot(id),
                          formatTimeSlot: formatTimeSlot,
                        ),
                        const SizedBox(height: 20),
                        BookingSummaryWidget(
                          selectedBookingSlots:
                              currentState.selectedBookingSlots,
                        ),
                        const SizedBox(height: 20),

                        FlexiblePaymentInput(
                          totalPrice: currentState.provisionalTotalPrice,
                          minRequiredDeposit: currentState.minRequiredDeposit,
                          onAmountChanged: (amount) {
                            cubit.setFlexiblePaymentAmount(amount);
                          },
                        ),
                      ],
                      const SizedBox(height: 30),
                      _buildConfirmButton(context, state, w, h),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Listener ---
  void _bookingListener(BuildContext context, BookingState state) {
    if (state is BookingSuccess) {
      showSnackBar(context, context.tr(state.message), Colors.green);
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (state is BookingSlotsUnavailable) {
      showSnackBar(context, context.tr(state.message), Colors.orange);
    } else if (state is BookingFailure) {
      showSnackBar(context, context.tr(state.errorMessage), Colors.red);
    }
  }

  // --- Confirm Button ---
  Widget _buildConfirmButton(
    BuildContext context,
    BookingState state,
    double w,
    double h,
  ) {
    if (state is BookingLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorManager.wasabi),
      );
    }

    // Check if button should be enabled
    bool isEnabled = false;
    if (state is BookingDataState &&
        state.selectedBookingSlots.isNotEmpty &&
        state.paidAmount >= state.minRequiredDeposit) {
      isEnabled = true;
    }

    return CustButton(
      h: h,
      w: w,
      color: isEnabled ? ColorManager.wasabi : Colors.grey[400]!,
      lable: context.tr('payNow'),
      size: 'mid',
      onTap: isEnabled
          ? () {
              final cubit = context.read<BookingCubit>();
              final currentState = cubit.state;

              if (currentState is BookingDataState) {
                // Directly process payment with the selected amount
                // The payment flow will handle booking confirmation after successful payment
                handleWalletPayment(
                  context,
                  currentState.paidAmount,
                  "01010101010", // TODO: Get actual phone number from user
                );
              }
            }
          : () {},
    );
  }
}
