import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/cubit/user_bookings_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/cubit/user_bookings_status.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/widgets/booking_card_widget.dart';

class MyBookingsViewBody extends StatelessWidget {
  const MyBookingsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return BlocBuilder<UserBookingsCubit, UserBookingsState>(
      builder: (context, state) {
        if (state is UserBookingsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (state is UserBookingsEmpty) {
          return Center(
            child: Text(
              context.tr('noBookingsFound'),
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        if (state is UserBookingsSuccess) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            itemCount: state.bookings.length,
            itemBuilder: (context, index) =>
                BookingCardWidget(booking: state.bookings[index]),
          );
        }

        return const Center(
          child: Text(
            "Error fetching data",
            style: TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }
}
