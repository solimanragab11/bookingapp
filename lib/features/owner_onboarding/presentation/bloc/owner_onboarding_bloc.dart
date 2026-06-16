import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/upgrade_to_owner_a_usecase.dart';

// ==================== EVENTS ====================
abstract class OwnerOnboardingEvent extends Equatable {
  const OwnerOnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadOwnerStatus extends OwnerOnboardingEvent {}

class AcceptAgreement extends OwnerOnboardingEvent {
  final bool accepted;
  const AcceptAgreement(this.accepted);

  @override
  List<Object?> get props => [accepted];
}

class UpgradeToOwnerA extends OwnerOnboardingEvent {
  final bool acceptedAgreement;
  const UpgradeToOwnerA(this.acceptedAgreement);

  @override
  List<Object?> get props => [acceptedAgreement];
}

// ==================== STATES ====================
abstract class OwnerOnboardingState extends Equatable {
  const OwnerOnboardingState();

  @override
  List<Object?> get props => [];
}

class OwnerOnboardingLoading extends OwnerOnboardingState {}

class OwnerBState extends OwnerOnboardingState {
  final bool agreementChecked;
  const OwnerBState({this.agreementChecked = false});

  @override
  List<Object?> get props => [agreementChecked];
}

class AgreementAcceptedState extends OwnerOnboardingState {}

class UpgradedState extends OwnerOnboardingState {}

class OwnerOnboardingError extends OwnerOnboardingState {
  final String message;
  const OwnerOnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================
class OwnerOnboardingBloc extends Bloc<OwnerOnboardingEvent, OwnerOnboardingState> {
  final UpgradeToOwnerAUseCase upgradeToOwnerAUseCase;

  OwnerOnboardingBloc({required this.upgradeToOwnerAUseCase}) : super(OwnerOnboardingLoading()) {
    on<LoadOwnerStatus>((event, emit) {
      emit(const OwnerBState(agreementChecked: false));
    });

    on<AcceptAgreement>((event, emit) {
      emit(OwnerBState(agreementChecked: event.accepted));
    });

    on<UpgradeToOwnerA>((event, emit) async {
      emit(OwnerOnboardingLoading());
      try {
        await upgradeToOwnerAUseCase(acceptedAgreement: event.acceptedAgreement);
        emit(UpgradedState());
      } catch (e) {
        emit(OwnerOnboardingError(e.toString()));
      }
    });
  }
}
