import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/my_bookings_header.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/my_bookings_view_body.dart';

class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final authUser = context.read<AuthCubit>().currentUser;

    return BlocProvider(
      create: (context) =>
          UserBookingsCubit(BookingService())
            ..fetchMyBookings(authUser?.id ?? ""),
      child: Scaffold(
        body: Stack(
          children: [
            BackGround(h: h, w: w),
            const SafeArea(
              child: Column(
                children: [
                  MyBookingsHeader(),
                  Expanded(child: MyBookingsViewBody()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
