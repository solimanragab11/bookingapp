import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_service.dart';
import 'package:remaking_booking_app_trail2/core/di/dependency_injection.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart'
    show PlaceModel;
import 'package:remaking_booking_app_trail2/core/models/subplace.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_Wrapper_states.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_wrapper.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/presentation/login_page.dart';
import 'package:remaking_booking_app_trail2/features/auth/repo/firebase_auth_repo_impl.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_cubit.dart.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/presentation/signup_page.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/data_sources/firestore_owner_service.dart';
import 'package:remaking_booking_app_trail2/features/owner/data/repos/owner_repo_impl.dart';
import 'package:remaking_booking_app_trail2/features/owner/logic/booking_management_cubit/booking_mng_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/logic/manage_place_cubit/manage_place_cubit.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/screens/add_place_page.dart';
import 'package:remaking_booking_app_trail2/features/admin/offer_mngmnt/presentation/offer_Screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/place_schedule/screen/place_schedule_screen.dart';
import 'package:remaking_booking_app_trail2/features/admin/add_place/widgets/map_selection_screen.dart';
import 'package:remaking_booking_app_trail2/features/owner/main_screen/screen/owner_main_screen.dart';
import 'package:remaking_booking_app_trail2/features/admin/show_all_places/all_screen.dart';
import 'package:remaking_booking_app_trail2/features/user/booking/presentation/booking_page.dart';
import 'package:remaking_booking_app_trail2/features/user/home/cubit/home_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/home/data/repos/home_repo.dart';
import 'package:remaking_booking_app_trail2/features/user/home/presentation/home_page.dart';
import 'package:remaking_booking_app_trail2/features/user/place_details/presentation/place_details_screen.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/cubit/user_bookings_cubit.dart';
import 'package:remaking_booking_app_trail2/features/user/user_bookings/presentation/user_bookings_page.dart';

/// ✅ App Router with proper provider management
/// This ensures ManageBookingPlaceCubit is properly scoped across routes
class AppRouter {
  /// ⚠️ IMPORTANT: Singleton instance of ManageBookingPlaceCubit
  /// Reusing the same instance prevents multiple instances and ensures proper scoping
  static ManageBookingPlaceCubit? _bookingCubitInstance;

  /// ✅ Get or create ManageBookingPlaceCubit instance (singleton pattern)
  static ManageBookingPlaceCubit _getBookingCubit() {
    if (_bookingCubitInstance == null) {
      final ownerServices = FirestoreOwnerService(AuthService());
      final ownerRepository = OwnerRepoImpl(ownerServices);
      _bookingCubitInstance = ManageBookingPlaceCubit(ownerRepository);
    }
    return _bookingCubitInstance!;
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final authService = AuthService();
    final authrepo = FirebaseAuthRepoImpl(authService);
    // final ownerServices = FirestoreOwnerService();
    final bookingService = BookingService();
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
            create: (context) => HomeCubit(bookingService as HomeRepo),
            child: const HomePage(),
          ),
        );
      case Routes.myBookings:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => UserBookingsCubit(bookingService),
            child: const MyBookingsPage(),
          ),
        );
      case Routes.addPlace:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ManagePlaceCubit(),
            child: const AddPlaceScreen(),
          ),
        );

      // ✅ FIXED: Owner Dashboard with proper BlocProvider setup
      case Routes.ownerDashboard:
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ManageBookingPlaceCubit>(
            // التعديل السحري: هنستخدم getIt مباشرة وننادي الداتا هنا
            create: (context) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthSuccess) print(authState.user.id);

              // بننادي الداتا "مرة واحدة" فقط عند خلق الـ Cubit
              return getIt<ManageBookingPlaceCubit>()..getMyPlacesOnce();
            },
            child: const OwnerMainScreen(),
          ),
        );
      // ✅ FIXED: Place Bookings Details with BlocProvider.value
      // This reuses the same Cubit instance from ownerDashboard
      case Routes.placeBookingsDetails:
        final PlaceModel place = settings.arguments as PlaceModel;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ManageBookingPlaceCubit>.value(
            value: _getBookingCubit(), // ✅ Reuse same instance
            child: PlaceScheduleScreen(placeId: place.id),
          ),
        );

      case Routes.placeDetails:
        final PlaceModel place = settings.arguments as PlaceModel;
        return MaterialPageRoute(
          builder: (_) => PlaceDetailsScreen(place: place),
          settings: settings,
        );

      // [map] and [mapSelection] share the same path string ('/map').
      case Routes.map:
        return MaterialPageRoute(
          builder: (_) => MapSelectionScreen(),
          settings: settings,
        );

      case Routes.bookingPage:
        final Map<String, dynamic> arguments =
            settings.arguments as Map<String, dynamic>;
        final PlaceModel place = arguments['place'];
        final SubPlace subPlace = arguments['subPlace'];
        return MaterialPageRoute(
          builder: (_) => BookingPage(place: place, subPlace: subPlace),
          settings: settings,
        );
      case Routes.activateOfferRoute:
        // بنستقبل البيانات المبعوثة كـ Map أو Arguments
        final args = settings.arguments as Map<String, dynamic>;
        final String placeId = args['placeId'];
        final String subPlaceId = args['subPlaceId'];

        return MaterialPageRoute(
          builder: (_) =>
              ActivateOfferScreen(placeId: placeId, subPlaceId: subPlaceId),
        );
      case Routes.adminSelectPlaceRoute:
        return MaterialPageRoute(
          builder: (_) => const AdminSelectPlaceScreen(),
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
