import 'package:hanzbthalk/core/repos/pricing_repository.dart';

class PricingRepositoryImpl implements PricingRepository {
  @override
  double calculateDiscountedPrice({
    required double originalPrice,
    required int points,
    required bool isOffer,
  }) {
    final discountFactor = isOffer ? (points / 100).clamp(0.0, 1.0) : 0.0;
    return originalPrice * (1.0 - discountFactor);
  }

  @override
  double calculateRequiredDeposit({
    required int slotCount,
    required bool isOwner,
  }) {
    if (slotCount <= 0) return 0.0;
    if (isOwner) {
      return (slotCount / 2.0) * 50.0;
    } else {
      return (((slotCount + 2) ~/ 3) * 100).toDouble();
    }
  }

  @override
  int calculatePointsToAdd({required double finalPrice}) {
    return 5;
  }

  @override
  double calculateRefund({
    required double amountPaidOnline,
    required double deposit,
    required DateTime bookingStartTime,
  }) {
    final minutesUntilBooking =
        (bookingStartTime.difference(DateTime.now()).inSeconds / 60.0).round();
    if (minutesUntilBooking > 360) {
      // Early Cancellation: User gets everything back minus 10 LE admin fee
      final refund = amountPaidOnline - 10.0;
      return refund < 0.0 ? 0.0 : refund;
    } else if (minutesUntilBooking >= 120) {
      // Medium Cancellation (2 to 6 hours): penalty of 50% of deposit for each 2 hours block + 10 LE fee
      final double blocks = ((360 - minutesUntilBooking) / 120.0).ceilToDouble();
      final penalty = (blocks * (deposit / 2.0)) + 10.0;
      final refund = amountPaidOnline - penalty;
      return refund < 0.0 ? 0.0 : refund;
    } else {
      // Less than 2 hours: Full penalty (no refund)
      return 0.0;
    }
  }
}
