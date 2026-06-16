import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/features/user/booking/cubit/booking_states.dart';
import 'package:hanzbthalk/features/user/booking/widgets/text_details_booking_widget.dart';

class BookingDetailsSection extends StatelessWidget {
  final PlaceModel place;
  final BookingDataState state;

  const BookingDetailsSection({
    super.key,
    required this.place,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return TextDetailsBookingWidget(
      w: MediaQuery.of(context).size.width,
      h: MediaQuery.of(context).size.height,
      place: place,
      subPlace: state.liveSubPlace!,
      availableDaysWithSlots: state.slots?.freeTimeSlots ?? {},
      selectedDay: state.selectedDay,
      onDaySelected: (day) {
        // cubit.selectDay(day!);
      },
    );
  }
}
