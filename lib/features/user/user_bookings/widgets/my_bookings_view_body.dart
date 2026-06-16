import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_status.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card_widget.dart';

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
          return _buildEmptyState(context);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorManager.cardSurface.withOpacity(0.4),
                border: Border.all(
                  color: ColorManager.egyptianEarth.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.egyptianEarth.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: ColorManager.egyptianEarth,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('noBookingsFound'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.tr('noBookingsSubtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.egyptianEarth,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: ColorManager.egyptianEarth.withOpacity(0.4),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                context.tr('exploreNow'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
