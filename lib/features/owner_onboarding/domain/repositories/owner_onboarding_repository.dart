abstract class OwnerOnboardingRepository {
  /// Upgrades user from owner_b to owner_a on the backend.
  Future<void> upgradeToOwnerA({required bool acceptedAgreement});
}
