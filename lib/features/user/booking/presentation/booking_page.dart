import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';
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
import 'package:hanzbthalk/features/user/booking/services/slot_lock_service.dart';

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
        getIt<SlotLockService>(),
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
                                            lockedSlots:
                                                bookingData.slots!.lockedSlots,
                                            currentUserId:
                                                context.read<AuthCubit>().currentUser?.id,
                                            onSlotToggled: (id) =>
                                                cubit.selectSlot(id),
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
                                        noShowCount: bookingData.noShowCount,
                                        penaltyBookingsLeft:
                                            bookingData.penaltyBookingsLeft,
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
                                          final double slotPrice =
                                              bookingData.finalAmount -
                                                  (bookingData.noShowCount == 1 ||
                                                          bookingData
                                                                  .penaltyBookingsLeft >
                                                              0
                                                      ? 50.0
                                                      : 0.0);
                                          final double half = (slotPrice / 2) +
                                              (bookingData.noShowCount == 1 ||
                                                      bookingData
                                                              .penaltyBookingsLeft >
                                                          0
                                                  ? 50.0
                                                  : 0.0);
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
      SnackBarUtils.showSuccess(context, state.message);
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (state is BookingFailure) {
      SnackBarUtils.showError(context, state.errorMessage);
    } else if (state is SlotLockSuccess) {
      SnackBarUtils.showSuccess(context, context.tr(state.messageKey));
    } else if (state is SlotLockFailure) {
      SnackBarUtils.showError(context, context.tr(state.errorMessageKey));
    } else if (state is PaymentLockSuccess) {
      SnackBarUtils.showSuccess(context, context.tr(state.messageKey));
    } else if (state is PaymentLockFailure) {
      SnackBarUtils.showError(context, context.tr(state.errorMessageKey));
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
          ? () {
              _showBookingRulesDialog(context, () async {
                final data = cubit.state as BookingDataState;
                final authUser = context.read<AuthCubit>().currentUser;

                // 1. Try to extend the lock to 10 minutes
                final lockSuccess = await cubit.proceedToPayment();
                if (!lockSuccess) {
                  // If lock extension fails, abort flow (listener handles error snackbar)
                  return;
                }

                // 2. Proceed to actual payment
                if (context.mounted) {
                  await handleWalletPayment(
                    context,
                    data.paidAmount,
                    authUser?.phoneNumber ?? "0000000000",
                  );
                }
              });
            }
          : () {},
    );
  }

  void _showBookingRulesDialog(BuildContext context, VoidCallback onAgree) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ColorManager.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: ColorManager.emeraldGreen.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.gavel_rounded,
                color: ColorManager.wasabi,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('bookingRulesTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('bookingRulesSubtitle'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                // Cancellation section title
                const Text(
                  "شروط الإلغاء والاسترداد / Cancellation & Refunds:",
                  style: TextStyle(
                    color: ColorManager.wasabi,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('ruleCancellation1'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('ruleCancellation2'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('ruleCancellation3'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const Divider(color: Colors.white12, height: 25),
                // Penalties section title
                const Text(
                  "نظام غرامات عدم الحضور / No-Show Penalties:",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('rulePenalty1'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('rulePenalty2'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('rulePenalty3'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                context.tr('cancelBtn'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.egyptianEarth,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onAgree();
              },
              child: Text(
                context.tr('agreeAndPay'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
