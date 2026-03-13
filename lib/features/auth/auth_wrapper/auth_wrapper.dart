import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // مهم جداً: أول ما الـ Wrapper يتفتح، لازم نطلب من الـ Cubit يشوف الحالة الحالية
    // ده اللي بيخلي الـ الـ Login يشتغل صح كل مرة حتى بعد الـ Logout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AuthCubit>()
          .checkAuthStatus(); // تأكد إن اسم الدالة عندك checkAuth أو عدله
    });

    print("=============================");
    print("AuthWrapper Initialized & Auth Checked");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        print("Auth State Changed to: ${state.runtimeType}");

        if (state is AuthSuccess) {
          print("Success! Role: ${state.role}");

          // بنستخدم الـ Navigator بشكل مباشر لأننا جوه الـ Listener
          if (state.role == 'owner') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.ownerDashboard,
              (route) =>
                  false, // بيمسح كل الـ Stack القديم عشان ميرجعش للـ Wrapper تاني
            );
          } else {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is AuthUnauthenticated) {
          print("User Unauthenticated - Navigating to Login");
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
        }
      },
      builder: (context, state) {
        final w = MediaQuery.of(context).size.width;

        // لو الحالة تحميل، بنعرض الـ Indicator
        if (state is AuthLoading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: w * 0.015,
                color: Colors.green, // أو لون البراند بتاعك
              ),
            ),
          );
        }

        // في أي حالة تانية، بنعرض شاشة فاضية لحد ما الـ Listener يوجهنا
        return Scaffold(
          body: Center(
            child: BackGround(
              h: size.height,
              w: size.width,
            ), // حماية إضافية لو الـ State اتأخرت
          ),
        );
      },
    );
  }
}
