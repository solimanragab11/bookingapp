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
}
