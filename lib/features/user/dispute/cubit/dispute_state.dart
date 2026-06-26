abstract class DisputeState {}

class DisputeInitial extends DisputeState {}

class DisputeLoading extends DisputeState {}

class DisputeSuccess extends DisputeState {
  final String messageKey;
  DisputeSuccess(this.messageKey);
}

class DisputeTooFar extends DisputeState {
  final int noShowCount;
  final int currentPoints;
  final String bookingId;
  final String userId;

  DisputeTooFar({
    required this.noShowCount,
    required this.currentPoints,
    required this.bookingId,
    required this.userId,
  });
}

class DisputeFailure extends DisputeState {
  final String errorMessage;
  DisputeFailure(this.errorMessage);
}
