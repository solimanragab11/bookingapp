abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingDataState extends BookingState {
  final String? selectedDay;
  final Set<String> selectedBookingSlots;
  final double provisionalTotalPrice;
  final double requiredDeposit;
  final double minRequiredDeposit;
  final double paidAmount;
  final double remainingAmount;

  BookingDataState({
    this.selectedDay,
    this.selectedBookingSlots = const {},
    this.provisionalTotalPrice = 0.0,
    this.requiredDeposit = 0.0,
    this.minRequiredDeposit = 0.0,
    this.paidAmount = 0.0,
    this.remainingAmount = 0.0,
  });

  BookingDataState copyWith({
    String? selectedDay,
    Set<String>? selectedBookingSlots,
    double? provisionalTotalPrice,
    double? requiredDeposit,
    double? minRequiredDeposit,
    double? paidAmount,
    double? remainingAmount,
  }) {
    return BookingDataState(
      selectedDay: selectedDay ?? this.selectedDay,
      selectedBookingSlots: selectedBookingSlots ?? this.selectedBookingSlots,
      provisionalTotalPrice:
          provisionalTotalPrice ?? this.provisionalTotalPrice,
      requiredDeposit: requiredDeposit ?? this.requiredDeposit,
      minRequiredDeposit: minRequiredDeposit ?? this.minRequiredDeposit,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
    );
  }
}

class BookingSuccess extends BookingState {
  final String message;
  BookingSuccess({required this.message});
}

class BookingFailure extends BookingState {
  final String errorMessage;
  BookingFailure({required this.errorMessage});
}

class BookingSlotsUnavailable extends BookingState {
  final String message;
  BookingSlotsUnavailable({required this.message});
}
