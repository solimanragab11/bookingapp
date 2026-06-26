import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hanzbthalk/core/db/push_notification_service.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/routes/routing.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/language/cubit/language_cubit.dart';

// 1. استيراد المكتبة

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint("Firebase Initialized ✅");

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    debugPrint("Firestore Offline Persistence Enabled 🚀");

    // Always initialize Dependency Injection (setupGetIt) to prevent crashes
    try {
      await setupGetIt();
      debugPrint("GetIt Initialized ✅");
    } catch (e) {
      debugPrint("Failed to initialize Dependency Injection: $e ❌");
    }

    try {
      await getIt<PushNotificationService>().init();
      debugPrint("Push Notification Service Initialized ✅");
    } catch (e) {
      debugPrint("Failed to initialize Push Notifications: $e ⚠️");
    }

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kDebugMode
            ? AndroidProvider.debug
            : AndroidProvider.playIntegrity,
      );
      debugPrint("App Check Initialized ✅");
    } catch (e) {
      debugPrint("Failed to initialize App Check: $e ⚠️");
    }
  } catch (e) {
    debugPrint("Error during Firebase initialization: $e ❌");
  }

  runApp(const BookingHubApp());
}

class BookingHubApp extends StatelessWidget {
  const BookingHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
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

            // نظام الراوتنج (Routing)
            navigatorKey: AppRouter.navigatorKey,
            onGenerateRoute: AppRouter.generateRoute,
            initialRoute: Routes.authWrapper, // البداية من صفحة التسجيل
          );
        },
      ),
    );
  }
}
