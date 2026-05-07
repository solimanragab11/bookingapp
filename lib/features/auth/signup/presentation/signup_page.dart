import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_textfiled.dart';
import 'package:remaking_booking_app_trail2/core/widgets/lang_button.dart';
import 'package:remaking_booking_app_trail2/core/widgets/signup_bottomsheet.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_cubit.dart.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Prevents opening the OTP sheet twice on rapid state changes.
  bool _otpSheetOpen = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // OTP bottom sheet
  // ---------------------------------------------------------------------------

  void _showOtpSheet(String verificationId) {
    if (_otpSheetOpen) return;
    _otpSheetOpen = true;

    // بنسحب الـ SignUpCubit اللي الصفحة شغالة بيه
    final signUpCubit = context.read<SignUpCubit>();

    SignupBottomSheet.showOTP(
      context: context,
      phoneNumber: _phoneController.text,
      signUpCubit: signUpCubit, // بنمرر الـ SignUpCubit الجديد
      onResend: () {
        signUpCubit.sendOTP(_phoneController.text);
      },
      onVerify: (smsCode) {
        signUpCubit.verifyOTP(username: _nameController.text, smsCode: smsCode);
      },
    ).then((_) {
      _otpSheetOpen = false;
      // نصيحة: لو الـ BottomSheet اتقفل والمستخدم لسه في حالة Loading
      // ممكن تعمل Reset للـ Cubit عشان الـ Circle تختفي
      if (signUpCubit.state is SignUpLoading) {
        signUpCubit.reset();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: const [LanguageToggleButton()],
        ),
        body: Stack(
          children: [
            BackGround(h: size.height, w: size.width),
            BlocListener<SignUpCubit, SignUpState>(
              listener: (context, state) {
                if (state is SignUpCodeSent) {
                  _showOtpSheet(state.verificationId);
                } else if (state is SignUpSuccess) {
                  // New user is authenticated — let AuthWrapper route them.
                  Navigator.pushReplacementNamed(context, Routes.authWrapper);
                } else if (state is SignUpError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(context.tr(state.messageKey)),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
              },
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 0.05),
                                FittedBox(
                                  child: Text(
                                    context.tr('appName'),
                                    style: TextStyleMangare.headingStyle
                                        .copyWith(
                                          fontSize: size.height * 0.06,
                                          color: ColorManager.wasabi,
                                        ),
                                  ),
                                ),
                                Text(
                                  context.tr('signup'),
                                  style: TextStyleMangare.headingStyle.copyWith(
                                    fontSize: size.height * 0.025,
                                    color: ColorManager.cardSurface,
                                  ),
                                ),
                                const Spacer(),
                                CustTextField(
                                  controller: _nameController,
                                  hint: context.tr('fullName'),
                                  icon: Icons.person_outline,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return context.tr('nameRequired');
                                    }
                                    if (v.trim().length < 2) {
                                      return context.tr('nameTooShort');
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: size.height * 0.02),
                                CustTextField(
                                  controller: _phoneController,
                                  hint: context.tr('phoneNumber'),
                                  icon: Icons.phone_android,
                                  isPhone: true,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return context.tr('phoneRequired');
                                    }
                                    if (v.trim().length < 10) {
                                      return context.tr('phoneInvalid');
                                    }
                                    return null;
                                  },
                                ),
                                const Spacer(),
                                BlocBuilder<SignUpCubit, SignUpState>(
                                  buildWhen: (prev, curr) =>
                                      curr is SignUpLoading ||
                                      curr is SignUpInitial ||
                                      curr is SignUpError ||
                                      curr is SignUpCodeSent,
                                  builder: (context, state) {
                                    if (state is SignUpLoading) {
                                      return const CircularProgressIndicator(
                                        color: ColorManager.wasabi,
                                      );
                                    }
                                    return CustButton(
                                      h: size.height,
                                      w: size.width,
                                      color: ColorManager.wasabi,
                                      size: 'mid',
                                      lable: context.tr('confirm'),
                                      onTap: () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<SignUpCubit>().sendOTP(
                                            _phoneController.text,
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                                const Spacer(flex: 2),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                        context,
                                        Routes.login,
                                      ),
                                  child: Text(
                                    context.tr('youAlreadyHaveAccountLogin'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
