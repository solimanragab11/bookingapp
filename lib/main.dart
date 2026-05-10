import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:remaking_booking_app_trail2/core/db/auth_service.dart';
import 'package:remaking_booking_app_trail2/core/di/dependency_injection.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/routes/routing.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:remaking_booking_app_trail2/features/language/cubit/language_cubit.dart';

// 1. استيراد المكتبة
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    debugPrint("Firebase Initialized ✅");

    await FirebaseAppCheck.instance.activate(
      // السطر ده مهم جداً للـ Android
      androidProvider: AndroidProvider.debug,
    );
    // String? token = await FirebaseAppCheck.instance.getToken();
    // debugPrint("سجل الـ Token ده عندك يا سولي: $token");
    // debugPrint("App Check Activated ✅");

    await setupGetIt();
    debugPrint("GetIt Initialized ✅");
  } catch (e) {
    debugPrint("Error during initialization: $e ❌");
  }

  runApp(const BookingHubApp());
}

class BookingHubApp extends StatelessWidget {
  const BookingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authService)..checkAuthStatus(),
        ),
        BlocProvider<LanguageCubit>(create: (context) => LanguageCubit()),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // استخدام الـ title المترجم
            onGenerateTitle: (context) => context.tr('appName'),

            // إعدادات اللغة
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // تحديد اللغة بناءً على إعدادات الجهاز لو مفيش اختيار يدوي
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (deviceLocale != null &&
                    deviceLocale.languageCode == supportedLocale.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },

            // إعدادات الـ Theme (الستايل الداكن اللي اخترناه)
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor:
                  Colors.black, // عشان يمشي مع الـ Background الزجاجي
              primaryColor: const Color(0xFF96B729), // لون الوسابي
            ),

            // نظام الراوتنج (Routing)
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: Routes.authWrapper, // البداية من صفحة التسجيل
          );
        },
      ),
    );
  }
}
  