import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/db/permission_service.dart';
import 'package:hanzbthalk/core/models/place_model.dart';
import 'package:hanzbthalk/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:hanzbthalk/features/admin/admin_dashboard/screen/admin_dashboard_screen.dart';
import 'package:hanzbthalk/features/admin/admin_dashboard/screen/refund_requests_screen.dart';
import 'package:hanzbthalk/features/admin/admin_home/logic/admin_home_cubit.dart';
import 'package:hanzbthalk/features/admin/admin_home/screens/admin_home_screen.dart';
import 'package:hanzbthalk/features/admin/mange_auth/logic/manage_auth_cubit.dart';
import 'package:hanzbthalk/features/admin/mange_auth/screen/manage_auth_screen.dart';

// Logic & Cubits
import 'package:hanzbthalk/features/auth/login/bloc/login_cubit.dart';
import 'package:hanzbthalk/features/auth/signup/cubit/signup_cubit.dart.dart';
import 'package:hanzbthalk/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/logic/global_dashboard_cubit.dart';
import 'package:hanzbthalk/features/owner/manage_employees/screens/permission_denied_screen.dart';
import 'package:hanzbthalk/features/user/check_booking/presentation/check_in_scanner_screen.dart';
import 'package:hanzbthalk/features/user/home/cubit/home_cubit.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';

// Screens
import 'package:hanzbthalk/features/admin/add_place/screens/add_place_page.dart';
import 'package:hanzbthalk/features/admin/add_place/widgets/map_selection_screen.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_wrapper.dart';
import 'package:hanzbthalk/features/auth/login/presentation/login_page.dart';
import 'package:hanzbthalk/features/auth/signup/presentation/signup_page.dart';
import 'package:hanzbthalk/features/owner/dashboard/screens/dashboard_screen.dart';
import 'package:hanzbthalk/features/owner/gloabal_dashboard/screens/global_dashboard_screen.dart';
import 'package:hanzbthalk/features/owner/main_screen/screen/owner_main_screen.dart';
import 'package:hanzbthalk/features/owner/place_schedule/screen/place_schedule_screen.dart';
import 'package:hanzbthalk/features/owner/manage_employees/logic/manage_employees_cubit.dart';
import 'package:hanzbthalk/features/owner/manage_employees/screens/manage_employees_screen.dart';
import 'package:hanzbthalk/features/user/home/presentation/home_page.dart';
import 'package:hanzbthalk/features/user/booking/presentation/booking_page.dart';
import 'package:hanzbthalk/features/user/place_details/presentation/place_details_screen.dart';
import 'package:hanzbthalk/features/user/user_bookings/presentation/user_bookings_page.dart';

// Onboarding
import 'package:hanzbthalk/features/owner_onboarding/presentation/bloc/owner_onboarding_bloc.dart';
import 'package:hanzbthalk/features/owner_onboarding/presentation/pages/owner_intro_page.dart';
import 'package:hanzbthalk/features/owner_onboarding/presentation/pages/owner_agreement_page.dart';
import 'package:hanzbthalk/features/owner_onboarding/presentation/pages/owner_pending_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Route protection guard: Redirect unauthenticated requests to the auth wrapper
    final publicRoutes = [Routes.authWrapper, Routes.login, Routes.signup];

    final authService = getIt<AuthService>();
    if (!authService.isUserLoggedIn() &&
        !publicRoutes.contains(settings.name)) {
      debugPrint(
        '[AppRouter] Route protection: blocking unauthenticated access to ${settings.name}',
      );
      return MaterialPageRoute(builder: (_) => const AuthWrapper());
    }

    switch (settings.name) {
      // ================= AUTH ROUTES =================
      case Routes.authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<LoginCubit>(),
            child: LoginPage(),
          ),
        );

      case Routes.signup:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<SignUpCubit>(),
            child: const SignupPage(),
          ),
        );

      // ================= USER ROUTES =================
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<HomeCubit>(),
            child: const HomePage(),
          ),
        );

      case Routes.myBookings:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<UserBookingsCubit>(),
            child: const MyBookingsPage(),
          ),
          settings: settings,
        );

      case Routes.placeDetails:
        final PlaceModel place = settings.arguments as PlaceModel;
        return MaterialPageRoute(
          builder: (_) => PlaceDetailsScreen(place: place),
          settings: settings,
        );

      case Routes.bookingPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              BookingPage(place: args['place'], subPlace: args['subPlace']),
        );

      // ================= ADMIN / ADD PLACE ROUTES =================

      case Routes.adminHome:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<AdminHomeCubit>(),
            child: const AdminHomeScreen(),
          ),
        );

      case Routes.addPlace:
        final place = settings.arguments as PlaceModel?;

        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<AddPlaceCubit>(),
            child: AddPlaceScreen(placeToEdit: place), // بنمرره هنا
          ),
        );

      case Routes.map:
        return MaterialPageRoute(
          builder: (_) => MapSelectionScreen(),
          settings: settings,
        );

      case Routes.adminDashboardScreen:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());

      case Routes.adminMangeAuth:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ManageAuthCubit>(),
            child: ManageAuthScreen(), // بنمرره هنا
          ),
        );

      case Routes.refundRequests:
        return MaterialPageRoute(builder: (_) => const RefundRequestsScreen());

      // ================= OWNER ROUTES =================
      case Routes.ownerMainScreen:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ManageBookingPlaceCubit>()..getMyPlacesOnce(),
            child: const OwnerMainScreen(),
          ),
        );

      case Routes.placeBookingsDetails:
        final PlaceModel place = settings.arguments as PlaceModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ManageBookingPlaceCubit>(),
            child: PlaceScheduleScreen(placeId: place.id),
          ),
        );

      case Routes.globalDashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<GlobalDashboardCubit>()
                  ..getGlobalDashboardData(month: DateTime.now()),
            child: const GlobalDashboardScreen(),
          ),
        );

      case Routes.ownerDashboard:
        final args = settings.arguments as Map<String, dynamic>;
        final placeId = args['placeId'] as String;
        final placeName = args['placeName'] as String;
        return MaterialPageRoute(
          builder: (_) =>
              OwnerDashboardScreen(placeId: placeId, placeName: placeName),
        );
      case Routes.checkInScanner:
        return MaterialPageRoute(builder: (_) => const CheckInScannerScreen());
      case Routes.manageEmployees:
        final authCubit = getIt<AuthCubit>();
        final currentUser = authCubit.currentUser;
        // Only block if a user is present and lacks the required permission
        if (currentUser != null &&
            !PermissionService.can(currentUser, 'manageEmployees')) {
          return MaterialPageRoute(
            builder: (_) => const ManageEmployeesPermissionDenied(),
          );
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                getIt<ManageEmployeesCubit>()..loadCurrentEmployees(),
            child: const ManageEmployeesScreen(),
          ),
        );

      // ================= OWNER ONBOARDING ROUTES =================
      case Routes.ownerIntro:
        return MaterialPageRoute(builder: (_) => const OwnerIntroPage());

      case Routes.ownerAgreement:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<OwnerOnboardingBloc>(),
            child: const OwnerAgreementPage(),
          ),
        );

      case Routes.ownerPending:
        return MaterialPageRoute(builder: (_) => const OwnerPendingPage());

      // ================= DEFAULT ERROR ROUTE =================
      default:
        return _errorRoute(settings);
    }
  }

  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
