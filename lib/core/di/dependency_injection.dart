import 'package:get_it/get_it.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_impl.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // 1. Firestore Service
  if (!getIt.isRegistered<FirestoreOwnerService>()) {
    getIt.registerLazySingleton<FirestoreOwnerService>(
      () => FirestoreOwnerService(AuthService()),
    );
  }

  // 2. Repository
  if (!getIt.isRegistered<OwnerRepoImpl>()) {
    getIt.registerLazySingleton<OwnerRepoImpl>(() => OwnerRepoImpl(getIt()));
  }

  // 3. Cubit
  if (!getIt.isRegistered<ManageBookingPlaceCubit>()) {
    getIt.registerLazySingleton<ManageBookingPlaceCubit>(
      () => ManageBookingPlaceCubit(getIt()),
    );
  }
}
