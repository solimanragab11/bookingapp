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

    print("Firebase Initialized ✅");

    // 2. تفعيل الـ App Check للـ Debug mode (ده اللي هيحل مشكلة الـ Log)
    // ده بيخلي Firebase يثق في الموبايل بتاعك وأنت شغال تطوير
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
    print("App Check Activated ✅");

    await setupGetIt();
    print("GetIt Initialized ✅");
  } catch (e) {
    print("Error during initialization: $e ❌");
  }

  runApp(const BookingHubApp());
}

class BookingHubApp extends StatelessWidget {
  const BookingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // تجهيز الـ Repository والـ Functions مرة واحدة ليتم حقنهم
    final authService = AuthService();

    return MultiBlocProvider(
      providers: [
        // حقن الـ AuthCubit بالـ Repository بتاعه
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authService)..checkAuthStatus(),
        ),
        // حقن كيوبيت اللغة
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
            initialRoute: Routes.login, // البداية من صفحة التسجيل
          );
        },
      ),
    );
  }
}
