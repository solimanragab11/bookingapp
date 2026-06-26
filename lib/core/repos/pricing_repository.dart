abstract class PricingRepository {
  double calculateDiscountedPrice({
    required double originalPrice,
    required int points,
    required bool isOffer,
  });

  double calculateRequiredDeposit({
    required int slotCount,
    required bool isOwner,
  });

  int calculatePointsToAdd({
    required double finalPrice,
  });

  double calculateRefund({
    required double amountPaidOnline,
    required double deposit,
    required DateTime bookingStartTime,
  });
}
