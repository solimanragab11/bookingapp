import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_Wrapper_states.dart';
import 'package:remaking_booking_app_trail2/features/auth/auth_wrapper/auth_cubit.dart';

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

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          _navigate(
            state.role == 'owner'
                ? Routes.ownerDashboard
                : state.role == 'admin'
                ? Routes.addPlace
                : Routes.home,
          );
        } else if (state is AuthUnauthenticated) {
          _navigate(Routes.login);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.messageKey),
              backgroundColor: Colors.red,
            ),
          );
          // After showing the error, fall back to login so the user is not stuck.
          _navigate(Routes.login);
        }
      },
      child: Scaffold(
        backgroundColor: ColorManager.noirDeVigne,
        body: Stack(
          children: [
            BackGround(h: size.height, w: size.width),
            const Center(
              child: CircularProgressIndicator(color: ColorManager.wasabi),
            ),
          ],
        ),
      ),
    );
  }
}
