abstract class EmployeeBookingState {}

class EmployeeBookingInitial extends EmployeeBookingState {}

class EmployeeBookingLoading extends EmployeeBookingState {}

class EmployeeBookingSuccess extends EmployeeBookingState {
  final String messageKey;
  EmployeeBookingSuccess(this.messageKey);
}

class EmployeeBookingFailure extends EmployeeBookingState {
  final String errorMessage;
  EmployeeBookingFailure(this.errorMessage);
}
