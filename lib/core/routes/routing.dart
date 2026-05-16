import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/di/dependency_injection.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/add_place_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_dashboard/screen/admin_dashboard_screen.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_home/logic/admin_home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/admin_home/screens/admin_home_screen.dart';
import 'package:remaking_booking_app_trail2/features/admin/mange_auth/logic/manage_auth_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/mange_auth/screen/manage_auth_screen.dart';

// Logic & Cubits
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_cubit.dart.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/logic/global_dashboard_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/cubit/user_bookings_cubit.dart';

// Screens
import 'package:remaking_booking_app_trail2/features/admin/add_place/screens/add_place_page.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/map_selection_screen.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_wrapper.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/presentation/login_page.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/presentation/signup_page.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/screens/dashboard_screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/gloabal_dashboard/screens/global_dashboard_screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/main_screen/screen/owner_main_screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/screen/place_schedule_screen.dart';
import 'package:remaking_booking_app_trail2/features/user/home/presentation/home_page.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/presentation/booking_page.dart';
import 'package:remaking_booking_app_trail2/features/user/place_details/presentation/place_details_screen.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/presentation/user_bookings_page.dart';
import 'package:remaking_booking_app_trail2/features/admin/offer_mngmnt/presentation/offer_Screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
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

      case Routes.activateOfferRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ActivateOfferScreen(
            placeId: args['placeId'],
            subPlaceId: args['subPlaceId'],
          ),
        );
      case Routes.adminMangeAuth:
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ManageAuthCubit>(),
            child: ManageAuthScreen(), // بنمرره هنا
          ),
        );

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
        final placeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OwnerDashboardScreen(placeId: placeId),
        );

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
