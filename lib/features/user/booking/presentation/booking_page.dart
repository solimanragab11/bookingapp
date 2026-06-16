import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/repos/pricing_repository.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/core/models/subplace_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/core/widgets/cust_button.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/user/booking/cubit/booking_cubit.dart';
import 'package:hanzbthalk/features/user/booking/cubit/booking_states.dart';
import 'package:hanzbthalk/features/user/booking/helpers/booking_helper.dart';
import 'package:hanzbthalk/features/user/booking/widgets/booking_header_image.dart';
import 'package:hanzbthalk/features/user/booking/widgets/booking_slots_grid.dart';
import 'package:hanzbthalk/features/user/booking/widgets/booking_summary_widget.dart';
import 'package:hanzbthalk/features/user/booking/widgets/flexible_payment_input.dart';
import 'package:hanzbthalk/features/user/booking/widgets/text_details_booking_widget.dart';

class BookingPage extends StatelessWidget with BookingHelper {
  final PlaceModel place;
  final SubPlaceModel subPlace;

  BookingPage({super.key, required this.place, required this.subPlace});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final imageHeight = h * 0.25;

    return BlocProvider(
      create: (context) => BookingCubit(
        getIt<BookingService>(),
        getIt<AuthService>(),
        getIt<PricingRepository>(),
      )..initializeBooking(place: place, subPlace: subPlace),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(context.tr('confirmBooking')),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            BackGround(h: h, w: w),
            BlocConsumer<BookingCubit, BookingState>(
              listener: _bookingListener,
              builder: (context, state) {
                final cubit = context.read<BookingCubit>();
                BookingDataState? currentState;

                if (state is BookingDataState) {
                  currentState = state;
                } else if (cubit.state is BookingDataState) {
                  currentState = cubit.state as BookingDataState;
                }

                final currentSubPlace = currentState?.liveSubPlace ?? subPlace;

                return Stack(
                  children: [
                    if (state is BookingFailure)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.redAccent.withOpacity(0.1),
                                  border: Border.all(
                                    color: Colors.redAccent.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.redAccent,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                context.tr(state.errorMessage),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.tr('error'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorManager.egyptianEarth,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: Text(context.tr('successButton')),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (currentState == null || currentState.slots == null)
                      const Center(
                        child: CircularProgressIndicator(
                          color: ColorManager.wasabi,
                        ),
                      )
                    else
                      Builder(
                        builder: (context) {
                          final bookingData = currentState!;
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                SizedBox(height: imageHeight - 20),
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(30),
                                  ),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      width: w,
                                      decoration: BoxDecoration(
                                        color: ColorManager.cardSurface.withOpacity(0.4),
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(30),
                                        ),
                                        border: Border(
                                          top: BorderSide(
                                            color: ColorManager.emeraldGreen.withOpacity(0.3),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: w * 0.04,
                                        vertical: h * 0.02,
                                      ),
                                      child: Column(
                                        children: [
                                          TextDetailsBookingWidget(
                                            w: w,
                                            h: h,
                                            place: place,
                                            subPlace: currentSubPlace,
                                            availableDaysWithSlots:
                                                bookingData.slots!.freeTimeSlots,
                                            selectedDay: bookingData.selectedDay,
                                            onDaySelected: (day) =>
                                                cubit.selectDay(day!),
                                          ),
                                          const SizedBox(height: 25),
                                          BookingSlotsGrid(
                                            selectedDay: bookingData.selectedDay!,
                                            selectedBookingSlots:
                                                bookingData.selectedBookingSlots,
                                            bookedTimeSlots:
                                                bookingData.slots!.bookedTimeSlots,
                                            onSlotToggled: (id) =>
                                                cubit.toggleTimeSlot(id),
                                            formatTimeSlot: formatTimeSlot,
                                            freeTimeSlots:
                                                bookingData.slots!.freeTimeSlots,
                                          ),
                                      const SizedBox(height: 20),
                                      BookingSummaryWidget(
                                        selectedBookingSlots:
                                            bookingData.selectedBookingSlots,
                                      ),
                                      const SizedBox(height: 20),
                                      FlexiblePaymentInput(
                                        currentFinalPrice:
                                            bookingData.finalAmount,
                                        originalTotalPrice:
                                            bookingData.originalTotalAmount,
                                        minDeposit:
                                            bookingData.minRequiredDeposit,
                                        paidAmount: bookingData.paidAmount,
                                        userPoints: bookingData.userPoints,
                                        selectedPoints: bookingData.usedPoints,
                                        isOfferEnabled: bookingData.isOffer,
                                        onOfferToggle: (enabled) {
                                          cubit.toggleOffer(enabled);
                                        },
                                        onPointsChanged: (pts) {
                                          cubit.updateUsedPoints(pts.toInt());
                                        },
                                        onAmountEntered: (amount) {
                                          cubit.updatePaidAmount(amount);
                                        },
                                        onMinDepositTap: () {
                                          cubit.updatePaidAmount(
                                            bookingData.minRequiredDeposit,
                                          );
                                        },
                                        onHalfPriceTap: () {
                                          final half =
                                              bookingData.finalAmount / 2;
                                          cubit.updatePaidAmount(half);
                                        },
                                        onFullPriceTap: () {
                                          cubit.updatePaidAmount(
                                            bookingData.finalAmount,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 30),
                                      _buildConfirmButton(context, state, w, h),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                              ],
                            ),
                          );
                        }
                      ),
                    BookingHeaderImage(
                      imageUrl: currentSubPlace.imageUrl,
                      height: imageHeight,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- الـ Listener والـ Button ---
  void _bookingListener(BuildContext context, BookingState state) {
    if (state is BookingSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(state.message)),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (state is BookingFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(state.errorMessage)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildConfirmButton(
    BuildContext context,
    BookingState state,
    double w,
    double h,
  ) {
    if (state is BookingLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorManager.egyptianEarth),
      );
    }

    final cubit = context.read<BookingCubit>();
    bool isEnabled = false;

    if (cubit.state is BookingDataState) {
      final data = cubit.state as BookingDataState;
      // الزرار يفتح لو مختار سلوتس ودافع على الأقل العربون
      isEnabled =
          data.selectedBookingSlots.isNotEmpty &&
          data.paidAmount >= data.minRequiredDeposit;
    }

    return CustButton(
      h: h,
      w: w,
      color: isEnabled ? ColorManager.egyptianEarth : ColorManager.cardSurface,
      lable: context.tr('payNow'),
      size: 'mid',
      onTap: isEnabled
          ? () async {
              // Show loading overlay
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(
                    color: ColorManager.egyptianEarth,
                  ),
                ),
              );
              final data = cubit.state as BookingDataState;
              final authUser = context.read<AuthCubit>().currentUser;

              // بنباصي الـ paidAmount اللي جاي من الـ FlexiblePaymentInput
              await handleWalletPayment(
                context,
                data.paidAmount,
                authUser?.phoneNumber ?? "0000000000",
              );
              Navigator.of(context).pop(); // close loading dialog
              Navigator.pop(context);
            }
          : () {},
    );
  }
}
