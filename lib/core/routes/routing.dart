import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart' show Place;
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_wrapper.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/presentation/login_page.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/firebase_auth_repo_impl.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_cubit.dart.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/presentation/signup_page.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_for_bookings.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/logic/manage_place_cubit/manage_place_cubit.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/screens/add_place_page.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/screen/place_schedule_screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/add_place/widgets/map_selection_screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/dashboard/screen/dashboard_screen.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/presentation/booking_page.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/data/repos/home_repo.dart';
import 'package:remaking_booking_app_trail2/features/user/home/presentation/home_page.dart';
import 'package:remaking_booking_app_trail2/features/user/place_details/presentation/place_details_screen.dart';
import 'package:remaking_booking_app_trail2/core/di/dependency_injection.dart'; // غير المسار حسب مكان ملف الـ DI عندك

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final authService = AuthService();
    final authrepo = FirebaseAuthRepoImpl(authService);
    final ownerServices = FirestoreOwnerService();

    switch (settings.name) {
      case Routes.authWrapper:
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => LoginCubit(authrepo),
            child: LoginPage(),
          ),
        );

      case Routes.signup:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => SignUpCubit(authrepo),
            child: const SignupPage(),
          ),
        );

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => HomeCubit(BookingService() as HomeRepo),
            child: const HomePage(),
          ),
        );

      case Routes.addPlace:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            // هنا بنحقن الـ Cubit وبنديله الـ Repo اللي عملناه
            create: (context) => ManagePlaceCubit(),
            child: const AddPlaceScreen(),
          ),
        );

      case Routes.ownerDashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                ManageBookingPlaceCubit(OwnerBookingRepository(ownerServices)),
            child: const DashBoard(),
          ),
        );

      case Routes.placeBookingsDetails:
        final place = settings.arguments as Place;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: getIt<ManageBookingPlaceCubit>(),
            child: PlaceScheduleScreen(place: place),
          ),
        );

      case Routes.placeDetails:
        final place = settings.arguments as Place;
        return MaterialPageRoute(
          builder: (_) => PlaceDetailsScreen(place: place),
          settings: settings,
        );

      case Routes.map:
        return MaterialPageRoute(
          builder: (_) => MapSelectionScreen(),
          settings: settings,
        );

      case Routes.bookingPage:
        final Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;
        final Place place = arguments['place'];
        final SubPlace subPlace = arguments['subPlace'];
        return MaterialPageRoute(
          builder: (_) => BookingPage(place: place, subPlace: subPlace),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: Text(
                  context.tr(
                    'routeNotFound',
                    defaultValue: 'Route Not Found ${settings.name}',
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}
