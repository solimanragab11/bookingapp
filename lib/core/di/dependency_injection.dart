import 'package:get_it/get_it.dart';
import 'package:remaking_booking_app_trail2/core/db/admin_services.dart';
// Core & Services
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_analytics_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/repo/add_place_repo.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_home/logic/admin_home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_home/repo/admin_home_repo.dart';
import 'package:remaking_booking_app_trail2/features/admin/mange_auth/logic/manage_auth_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/firebase_auth_repo_impl.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_cubit.dart.dart';
// Features: Owner
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_impl.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/repo/global_dashboard_repository.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/logic/dashboard_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/logic/global_dashboard_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/repos/home_repo.dart';
// Features: Auth (مهم جداً لحل مشكلة الصورة)

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // ================= 1. Core & Services =================

  if (!getIt.isRegistered<AuthService>()) {
    getIt.registerLazySingleton<AuthService>(() => AuthService());
  }

  if (!getIt.isRegistered<BookingAnalyticsService>()) {
    getIt.registerLazySingleton<BookingAnalyticsService>(
      () => BookingAnalyticsService(),
    );
  }
  if (!getIt.isRegistered<BookingService>()) {
    getIt.registerLazySingleton<BookingService>(() => BookingService());
  }

  if (!getIt.isRegistered<FirestoreOwnerService>()) {
    getIt.registerLazySingleton<FirestoreOwnerService>(
      () => FirestoreOwnerService(getIt<AuthService>()),
    );
  }
  if (!getIt.isRegistered<AdminService>()) {
    getIt.registerLazySingleton<AdminService>(() => AdminService());
  }

  // ================= 2. Repositories =================

  // الـ Repo الخاص بالدخول (Login) - حل مشكلة الـ Crash
  if (!getIt.isRegistered<FirebaseAuthRepoImpl>()) {
    getIt.registerLazySingleton<FirebaseAuthRepoImpl>(
      () =>
          FirebaseAuthRepoImpl(getIt<AuthService>()), // تأكد من اسم الكلاس عندك
    );
  }

  if (!getIt.isRegistered<HomeRepoImpl>()) {
    getIt.registerLazySingleton<HomeRepoImpl>(
      () => HomeRepoImpl(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<AdminHomeRepoImpl>()) {
    getIt.registerLazySingleton<AdminHomeRepoImpl>(
      () => AdminHomeRepoImpl(getIt<BookingService>()),
    );
  }
  if (!getIt.isRegistered<OwnerRepoImpl>()) {
    getIt.registerLazySingleton<OwnerRepoImpl>(
      () => OwnerRepoImpl(getIt<FirestoreOwnerService>()),
    );
  }

  if (!getIt.isRegistered<GlobalDashboardRepository>()) {
    getIt.registerLazySingleton<GlobalDashboardRepository>(
      () => GlobalDashboardRepository(
        getIt<BookingAnalyticsService>(),
        getIt<AuthService>(),
      ),
    );
  }

  if (!getIt.isRegistered<AddPlaceRepo>()) {
    getIt.registerLazySingleton<AddPlaceRepo>(
      () => AddPlaceRepo(getIt<AdminService>(), getIt<AuthService>()),
    );
  }
  // ================= 3. Cubits (Logic) =================

  if (!getIt.isRegistered<LoginCubit>()) {
    getIt.registerFactory<LoginCubit>(
      () => LoginCubit(getIt<FirebaseAuthRepoImpl>()),
    );
  }
  if (!getIt.isRegistered<SignUpCubit>()) {
    getIt.registerFactory<SignUpCubit>(
      () => SignUpCubit(getIt<FirebaseAuthRepoImpl>()),
    );
  }
  if (!getIt.isRegistered<HomeCubit>()) {
    getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<HomeRepoImpl>()));
  }
  if (!getIt.isRegistered<AdminHomeCubit>()) {
    getIt.registerFactory<AdminHomeCubit>(
      () => AdminHomeCubit(getIt<AdminHomeRepo>()),
    );
  }
  if (!getIt.isRegistered<ManageAuthCubit>()) {
    getIt.registerFactory<ManageAuthCubit>(
      () => ManageAuthCubit(getIt<AdminService>()),
    );
  }
  if (!getIt.isRegistered<AddPlaceCubit>()) {
    getIt.registerFactory<AddPlaceCubit>(
      () => AddPlaceCubit(getIt<AddPlaceRepo>()),
    );
  }

  if (!getIt.isRegistered<ManageBookingPlaceCubit>()) {
    getIt.registerLazySingleton<ManageBookingPlaceCubit>(
      () => ManageBookingPlaceCubit(getIt<OwnerRepoImpl>()),
    );
  }

  if (!getIt.isRegistered<GlobalDashboardCubit>()) {
    getIt.registerFactory<GlobalDashboardCubit>(
      () => GlobalDashboardCubit(getIt<GlobalDashboardRepository>()),
    );
  }

  if (!getIt.isRegistered<DashboardCubit>()) {
    getIt.registerFactory<DashboardCubit>(() => DashboardCubit());
  }
}
