import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/language/cubit/language_cubit.dart';
import '../bloc/owner_onboarding_bloc.dart';

class OwnerAgreementPage extends StatefulWidget {
  const OwnerAgreementPage({super.key});

  @override
  State<OwnerAgreementPage> createState() => _OwnerAgreementPageState();
}

class _OwnerAgreementPageState extends State<OwnerAgreementPage> {
  @override
  void initState() {
    super.initState();
    // Load status on entry
    context.read<OwnerOnboardingBloc>().add(LoadOwnerStatus());
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';

    return BlocConsumer<OwnerOnboardingBloc, OwnerOnboardingState>(
      listener: (context, state) {
        if (state is UpgradedState) {
          // Success: Refresh user data and navigate directly
          context.read<AuthCubit>().refreshUserData();
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.ownerMainScreen, (_) => false);
        } else if (state is OwnerOnboardingError) {
          // Failure: Display error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        bool isChecked = false;
        bool isLoading = state is OwnerOnboardingLoading;

        if (state is OwnerBState) {
          isChecked = state.agreementChecked;
        }

        return Scaffold(
          backgroundColor: ColorManager.noirDeVigne,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              isAr ? "اتفاقية الانضمام" : "Membership Agreement",
              style: const TextStyle(
                color: ColorManager.creasedKhaki,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
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
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Graphic Icon/Visual
                      Icon(
                        Icons.assignment_turned_in,
                        size: 80,
                        color: ColorManager.creasedKhaki.withOpacity(0.9),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isAr
                            ? "خطوة واحدة تفصلك عن الترقية"
                            : "One step away from upgrading",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAr
                            ? "الرجاء تأكيد موافقتك على اتفاقية الشروط والسياسات للاستمرار في تفعيل حساب المالك والحصول على كامل الصلاحيات."
                            : "Please confirm your agreement to the terms and policies to continue activating your owner account and gain full access.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Checkbox agreement tile
                      Theme(
                        data: ThemeData(
                          unselectedWidgetColor: ColorManager.wasabi,
                        ),
                        child: CheckboxListTile(
                          value: isChecked,
                          onChanged: isLoading
                              ? null
                              : (val) {
                                  context.read<OwnerOnboardingBloc>().add(
                                    AcceptAgreement(val ?? false),
                                  );
                                },
                          activeColor: ColorManager.egyptianEarth,
                          checkColor: Colors.white,
                          title: Text(
                            context.tr('owner_agree_button'),
                            style: const TextStyle(
                              color: ColorManager.creasedKhaki,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Upgrade button
                      ElevatedButton(
                        onPressed: (!isChecked || isLoading)
                            ? null
                            : () {
                                context.read<OwnerOnboardingBloc>().add(
                                  UpgradeToOwnerA(isChecked),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.egyptianEarth,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.withOpacity(0.2),
                          disabledForegroundColor: Colors.white38,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.tr('owner_continue'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Decline button
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(
                                  context,
                                ).pushNamed(Routes.ownerPending);
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(
                            color: ColorManager.emeraldGreen,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          context.tr('owner_decline'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: ColorManager.egyptianEarth,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
