import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/cubit/booking_states.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/helpers/booking_helper.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/booking_header_image.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/booking_slots_grid.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/booking_summary_widget.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/flexible_payment_input.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/widgets/text_details_booking_widget.dart';

class BookingPage extends StatelessWidget with BookingHelper {
  final PlaceModel place;
  final SubPlace subPlace;

  BookingPage({super.key, required this.place, required this.subPlace});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final imageHeight = h * 0.25;

    return BlocProvider(
      create: (context) =>
          BookingCubit(BookingService(), AuthService())
            ..initializeBooking(place: place, subPlace: subPlace),
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
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('places')
                  .doc(place.id)
                  .snapshots(),
              builder: (context, snapshot) {
                SubPlace liveSubPlace = subPlace;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final List<dynamic> subList = data['subPlaces'] ?? [];
                  final updatedData = subList.firstWhere(
                    (e) =>
                        e['id'] == subPlace.id ||
                        e['name'] == subPlace.id, // تأكد من الـ ID الصح
                    orElse: () => null,
                  );
                  if (updatedData != null) {
                    liveSubPlace = SubPlace.fromJson(
                      updatedData as Map<String, dynamic>,
                    );
                    context.read<BookingCubit>().updateLiveSubPlace(
                      liveSubPlace,
                    );
                  }
                }

                return Stack(
                  children: [
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

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: imageHeight - 20),
                              Container(
                                width: w,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                    0.1,
                                  ), // خليته 0.9 عشان الداتا تبان بوضوح
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(30),
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: w * 0.04,
                                  vertical: h * 0.02,
                                ),
                                child: Column(
                                  children: [
                                    if (currentState != null) ...[
                                      TextDetailsBookingWidget(
                                        w: w,
                                        h: h,
                                        place: place,
                                        subPlace: liveSubPlace,
                                        availableDaysWithSlots:
                                            liveSubPlace.freeTimeSlots,
                                        selectedDay: currentState.selectedDay,
                                        onDaySelected: (day) =>
                                            cubit.selectDay(day!),
                                      ),
                                      const SizedBox(height: 25),
                                      BookingSlotsGrid(
                                        selectedDay: currentState.selectedDay!,
                                        selectedBookingSlots:
                                            currentState.selectedBookingSlots,
                                        bookedTimeSlots:
                                            liveSubPlace.bookedTimeSlots,
                                        onSlotToggled: (id) =>
                                            cubit.toggleTimeSlot(id),
                                        formatTimeSlot: formatTimeSlot,
                                        freeTimeSlots:
                                            liveSubPlace.freeTimeSlots,
                                      ),
                                      const SizedBox(height: 20),
                                      BookingSummaryWidget(
                                        selectedBookingSlots:
                                            currentState.selectedBookingSlots,
                                      ),
                                      const SizedBox(height: 20),

                                      // --- هنا تطبيق الـ FlexiblePaymentInput الجديد ---
                                      // استخدمنا FutureBuilder عشان نجيب النقاط "لايف"
                                      // --- داخل الـ build بتاع الـ BookingPage ---
                                      FutureBuilder<int>(
                                        future: cubit.getUserPoints(),
                                        builder: (context, pointsSnapshot) {
                                          // نجيب النقط الحقيقية من الـ snapshot أو نحط 0 لو لسه بيحمل
                                          final actualUserPoints =
                                              pointsSnapshot.data ?? 0;

                                          return FlexiblePaymentInput(
                                            // السعر النهائي المحسوب (بالخصم لو متفعل)
                                            currentFinalPrice:
                                                currentState?.finalAmount ??
                                                currentState
                                                    ?.originalTotalAmount ??
                                                0.0,

                                            // السعر الأصلي "الميزان" اللي مش بيتغير
                                            originalTotalPrice:
                                                currentState
                                                    ?.originalTotalAmount ??
                                                0.0,

                                            // المبلغ اللي اليوزر كتبه يدفع دلوقتي
                                            paidAmount:
                                                currentState?.paidAmount ?? 0.0,

                                            // إجمالي نقاط اليوزر الحقيقية
                                            userPoints: actualUserPoints,

                                            // النقاط اللي اليوزر اختارها من السلايدر حالياً
                                            selectedPoints:
                                                currentState?.usedPoints ?? 0,

                                            // حالة مفتاح العرض (Toggle)
                                            isOfferEnabled:
                                                currentState?.isOffer ?? false,
                                            minDeposit:
                                                currentState
                                                    ?.minRequiredDeposit ??
                                                0,
                                            // --- الربط الفعلي مع الـ Cubit ---

                                            // لما اليوزر يفتح أو يقفل الـ Switch
                                            onOfferToggle: (isOffer) {
                                              cubit.toggleOffer(isOffer);
                                            },

                                            // لما اليوزر يحرك السلايدر بتاع النقاط
                                            onPointsChanged: (points) {
                                              cubit.updateUsedPoints(
                                                points.toInt(),
                                              );
                                            },

                                            // لما اليوزر يكتب مبلغ يدوي
                                            onAmountEntered: (amount) {
                                              cubit.updatePaidAmount(amount);
                                            },

                                            // لما يدوس على "أقل عربون"
                                            onMinDepositTap: () {
                                              cubit.updatePaidAmount(
                                                currentState
                                                        ?.minRequiredDeposit ??
                                                    0.0,
                                              );
                                            },

                                            // لما يدوس على "نصف المبلغ"
                                            onHalfPriceTap: () {
                                              final half =
                                                  (currentState?.finalAmount ??
                                                      0.0) /
                                                  2;
                                              cubit.updatePaidAmount(half);
                                            },

                                            // لما يدوس على "كامل المبلغ"
                                            onFullPriceTap: () {
                                              cubit.updatePaidAmount(
                                                currentState?.finalAmount ??
                                                    0.0,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                    const SizedBox(height: 30),
                                    _buildConfirmButton(context, state, w, h),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    BookingHeaderImage(
                      imageUrl: liveSubPlace.imageUrl,
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
        child: CircularProgressIndicator(color: ColorManager.wasabi),
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
      color: isEnabled ? ColorManager.wasabi : Colors.grey[400]!,
      lable: context.tr('payNow'),
      size: 'mid',
      onTap: isEnabled
          ? () {
              final data = cubit.state as BookingDataState;
              final authUser = context.read<AuthCubit>().currentUser;

              // بنباصي الـ paidAmount اللي جاي من الـ FlexiblePaymentInput
              handleWalletPayment(
                context,
                data.paidAmount,
                authUser?.phoneNumber ?? "0000000000",
              );
              Navigator.pop(context);
            }
          : () {},
    );
  }
}
