import 'package:get_it/get_it.dart';
import 'package:hanzbthalk/core/db/admin_services.dart';
// Core & Services
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/db/booking_analytics_service.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/features/user/booking/services/slot_lock_service.dart';
import 'package:hanzbthalk/core/repos/pricing_repository.dart';
import 'package:hanzbthalk/core/repos/pricing_repository_impl.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:hanzbthalk/features/admin/add_place/repo/add_place_repo.dart';
import 'package:hanzbthalk/features/admin/admin_home/logic/admin_home_cubit.dart';
import 'package:hanzbthalk/features/admin/admin_home/repo/admin_home_repo.dart';
import 'package:hanzbthalk/features/admin/mange_auth/logic/manage_auth_cubit.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/auth/login/bloc/login_cubit.dart';
import 'package:hanzbthalk/features/auth/repo/firebase_auth_repo_impl.dart';
import 'package:hanzbthalk/features/auth/signup/cubit/signup_cubit.dart.dart';
import 'package:hanzbthalk/core/db/push_notification_service.dart';
// Features: Owner
import 'package:hanzbthalk/core/db/firestore_owner_service.dart';
import 'package:hanzbthalk/features/owner/repos/owner_repo_impl.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/repo/global_dashboard_repository.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:hanzbthalk/features/owner/dashboard/logic/dashboard_cubit.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/logic/global_dashboard_cubit.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_cubit.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_cubit.dart';
import 'package:hanzbthalk/features/user/check_booking/cubit/check_in_cubit.dart';
import 'package:hanzbthalk/features/user/dispute/cubit/dispute_cubit.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/home/repos/home_repo.dart';
// Features: Auth (مهم جداً لحل مشكلة الصورة)

// Owner Onboarding
import 'package:hanzbthalk/features/owner_onboarding/domain/repositories/owner_onboarding_repository.dart';
import 'package:hanzbthalk/features/owner_onboarding/domain/usecases/upgrade_to_owner_a_usecase.dart';
import 'package:hanzbthalk/features/owner_onboarding/data/repositories/owner_onboarding_repository_impl.dart';
import 'package:hanzbthalk/features/owner_onboarding/presentation/bloc/owner_onboarding_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // ================= 1. Core & Services =================

  if (!getIt.isRegistered<PushNotificationService>()) {
    getIt.registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(),
    );
  }

  if (!getIt.isRegistered<PricingRepository>()) {
    getIt.registerLazySingleton<PricingRepository>(
      () => PricingRepositoryImpl(),
    );
  }

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

  if (!getIt.isRegistered<SlotLockService>()) {
    getIt.registerLazySingleton<SlotLockService>(() => SlotLockService());
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

  // Owner Onboarding Repo & Usecase
  if (!getIt.isRegistered<OwnerOnboardingRepository>()) {
    getIt.registerLazySingleton<OwnerOnboardingRepository>(
      () => OwnerOnboardingRepositoryImpl(),
    );
  }
  if (!getIt.isRegistered<UpgradeToOwnerAUseCase>()) {
    getIt.registerLazySingleton<UpgradeToOwnerAUseCase>(
      () => UpgradeToOwnerAUseCase(getIt<OwnerOnboardingRepository>()),
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
  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerLazySingleton<AuthCubit>(
      () => AuthCubit(getIt<AuthService>(), getIt<FirebaseAuthRepoImpl>()),
    );
  }
  if (!getIt.isRegistered<HomeCubit>()) {
    getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<HomeRepoImpl>()));
  }
  if (!getIt.isRegistered<AdminHomeCubit>()) {
    getIt.registerFactory<AdminHomeCubit>(
      () => AdminHomeCubit(getIt<AdminHomeRepoImpl>()),
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
      () => ManageBookingPlaceCubit(
        getIt<OwnerRepoImpl>(),
        getIt<PricingRepository>(),
      ),
      dispose: (cubit) => cubit.close(),
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

  if (!getIt.isRegistered<ManageEmployeesCubit>()) {
    getIt.registerFactory<ManageEmployeesCubit>(
      () => ManageEmployeesCubit(
        getIt<FirestoreOwnerService>(),
        getIt<AuthService>(),
      ),
    );
  }

  // Owner Onboarding Bloc
  if (!getIt.isRegistered<OwnerOnboardingBloc>()) {
    getIt.registerFactory<OwnerOnboardingBloc>(
      () => OwnerOnboardingBloc(
        upgradeToOwnerAUseCase: getIt<UpgradeToOwnerAUseCase>(),
      ),
    );
  }

  // 🎯 تسجيل الـ CheckInCubit الجديد لإثبات الحضور بالـ QR
  if (!getIt.isRegistered<CheckInCubit>()) {
    getIt.registerFactory<CheckInCubit>(() => CheckInCubit());
  }

  // 🎯 تسجيل الـ EmployeeBookingCubit للـ No-Show والـ Cash PIN
  if (!getIt.isRegistered<EmployeeBookingCubit>()) {
    getIt.registerFactory<EmployeeBookingCubit>(() => EmployeeBookingCubit());
  }

  // 🎯 تسجيل الـ DisputeCubit للنزاع والـ GPS
  if (!getIt.isRegistered<DisputeCubit>()) {
    getIt.registerFactory<DisputeCubit>(() => DisputeCubit());
  }
}
