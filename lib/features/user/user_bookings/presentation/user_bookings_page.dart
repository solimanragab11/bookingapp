import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_status.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/my_bookings_header.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/my_bookings_view_body.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final authUser = context.read<AuthCubit>().currentUser;
    final targetBookingId = ModalRoute.of(context)?.settings.arguments as String?;

    return BlocProvider(
      create: (context) =>
          UserBookingsCubit(BookingService())
            ..fetchMyBookings(authUser?.id ?? ""),
      child: BlocListener<UserBookingsCubit, UserBookingsState>(
        listener: (context, state) {
          if (state is UserBookingsCancelSuccess) {
            final double refund = state.refundedAmount;
            final message = context.tr(
              'cancel_success_msg',
              defaultValue: 'Your booking was cancelled, and {} EGP was refunded to your wallet.',
            ).replaceAll('{}', refund.toStringAsFixed(0));
            SnackBarUtils.showSuccess(context, message);
          } else if (state is UserBookingsCancelFailure) {
            SnackBarUtils.showError(context, 'cancel_error_msg');
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Stack(
              children: [
                BackGround(h: h, w: w),
                SafeArea(
                  child: Column(
                    children: [
                      const MyBookingsHeader(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorManager.cardSurface.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: ColorManager.cardSurface.withOpacity(0.4),
                              width: 1.0,
                            ),
                          ),
                          child: Builder(
                            builder: (context) {
                              return TabBar(
                                indicator: BoxDecoration(
                                  color: ColorManager.egyptianEarth.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                dividerColor: Colors.transparent,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white60,
                                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                tabs: [
                                  Tab(text: context.tr('upcoming_bookings_tab')),
                                  Tab(text: context.tr('refund_requests_tab')),
                                ],
                              );
                            }
                          ),
                        ),
                      ),
                      Expanded(
                        child: MyBookingsViewBody(targetBookingId: targetBookingId),
                      ),
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
}
