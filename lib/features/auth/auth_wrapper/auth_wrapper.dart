import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/widgets/background.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_wrapper_states.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';

import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthCubit>().checkAuthStatus();
      }
    });
  }

  void _navigate(String route) {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final locale = Localizations.localeOf(context);
    final isAr = locale.languageCode == 'ar';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.role == 'owner_b') {
            _navigate(Routes.ownerIntro);
          } else if (state.role == 'owner' || state.role == 'employee') {
            _navigate(Routes.ownerMainScreen);
          } else if (state.role == 'admin') {
            _navigate(Routes.adminDashboardScreen);
          } else {
            _navigate(Routes.home);
          }
        } else if (state is AuthUnauthenticated) {
          _navigate(Routes.login);
        } else if (state is AuthFailure && state.messageKey != 'networkError') {
          SnackBarUtils.showError(context, state.messageKey);
          // After showing the error, fall back to login so the user is not stuck.
          _navigate(Routes.login);
        }
      },
      child: Scaffold(
        backgroundColor: ColorManager.noirDeVigne,
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthFailure && state.messageKey == 'networkError') {
              return Stack(
                children: [
                  BackGround(h: size.height, w: size.width),
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ColorManager.cardSurface.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorManager.wasabi.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.redAccent,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isAr ? "مشكلة في الاتصال" : "Connection Error",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAr
                                ? "لم نتمكن من الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى."
                                : "Could not connect to the server. Please check your internet connection and try again.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<AuthCubit>().checkAuthStatus();
                            },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            ),
                            label: Text(
                              isAr ? "إعادة المحاولة" : "Retry",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.wasabi,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Stack(
              children: [
                BackGround(h: size.height, w: size.width),
                const Center(
                  child: CircularProgressIndicator(color: ColorManager.wasabi),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
