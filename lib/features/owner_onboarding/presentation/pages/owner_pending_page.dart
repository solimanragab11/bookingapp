import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/language/cubit/language_cubit.dart';

class OwnerPendingPage extends StatelessWidget {
  const OwnerPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isAr ? "حالة الحساب معلقة" : "Account Status: Pending",
          style: const TextStyle(
            color: ColorManager.creasedKhaki,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.authWrapper, (_) => false);
            },
          ),
          TextButton(
            onPressed: () {
              final newLang = isAr ? 'en' : 'ar';
              context.read<LanguageCubit>().changeLanguage(newLang);
            },
            child: Text(
              isAr ? 'English' : 'العربية',
              style: const TextStyle(
                color: ColorManager.wasabi,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security / Lock illustration
              Icon(
                Icons.lock_clock,
                size: 90,
                color: ColorManager.egyptianEarth.withOpacity(0.9),
              ),
              const SizedBox(height: 30),
              Text(
                isAr ? "قيود الحساب النشطة" : "Active Account Restrictions",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ColorManager.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorManager.emeraldGreen),
                ),
                child: Text(
                  context.tr('owner_pending_message'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Button: Resume/Complete onboarding
              ElevatedButton(
                onPressed: () {
                  // Direct back to onboarding start
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.ownerIntro, (_) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.egyptianEarth,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isAr ? "بدء الموافقة على الشروط" : "Start Agreeing to Terms",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to login/logout option
              TextButton(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.authWrapper, (_) => false);
                },
                child: Text(
                  isAr ? "تسجيل الخروج والعودة للرئيسية" : "Logout & Exit",
                  style: const TextStyle(
                    color: ColorManager.wasabi,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
