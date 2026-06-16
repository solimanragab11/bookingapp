import '../repositories/owner_onboarding_repository.dart';

class UpgradeToOwnerAUseCase {
  final OwnerOnboardingRepository repository;

  UpgradeToOwnerAUseCase(this.repository);

  Future<void> call({required bool acceptedAgreement}) async {
    return await repository.upgradeToOwnerA(acceptedAgreement: acceptedAgreement);
  }
}
