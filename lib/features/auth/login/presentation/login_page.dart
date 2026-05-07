import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';
import 'package:remaking_booking_app_trail2/core/widgets/login_bottomsheet.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_textfiled.dart';
import 'package:remaking_booking_app_trail2/core/widgets/lang_button.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_states.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Flag لمنع تكرار فتح الـ BottomSheet
  // ignore: unused_field
  bool _otpSheetOpen = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // OTP bottom sheet logic
  // ---------------------------------------------------------------------------
  void _showOtpSheet(String verificationId) {
    // بنشيل شرط الـ if (_otpSheetOpen) عشان نسمح لها تفتح تاني لو اليوزر قفلها يدوي
    _otpSheetOpen = true;

    final cubit = context.read<LoginCubit>();

    AuthBottomSheet.showOTP(
      context: context,
      loginCubit: cubit,
      phoneNumber: _phoneController.text,
      onResend: () => cubit.sendLoginOTP(_phoneController.text),
      onVerify: (smsCode) => cubit.verifyLoginOTP(
        verificationId: verificationId,
        smsCode: smsCode,
      ),
    ).then((_) {
      // السطر ده سحر! لما الـ BottomSheet يقفل (بأي طريقة)، بنصفر الـ Flag
      _otpSheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginCodeSent) {
                _showOtpSheet(state.verificationId);
              } else if (state is LoginSuccess) {
                _otpSheetOpen = false;
                if (Navigator.canPop(context)) Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.authWrapper);
              } else if (state is LoginError) {
                _otpSheetOpen = false;
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: size.height * 0.05),
                              FittedBox(
                                child: Text(
                                  context.tr('appName'),
                                  style: TextStyleMangare.headingStyle.copyWith(
                                    fontSize: size.height * 0.065,
                                    color: ColorManager.wasabi,
                                  ),
                                ),
                              ),
                              Text(
                                context.tr('welcomeBack'),
                                style: TextStyleMangare.headingStyle.copyWith(
                                  fontSize: size.height * 0.025,
                                ),
                              ),
                              const Spacer(),
                              CustTextField(
                                controller: _phoneController,
                                hint: context.tr('phoneNumber'),
                                icon: Icons.phone_android,
                                isPhone: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.tr('phoneRequired');
                                  }
                                  if (value.trim().length < 10) {
                                    return context.tr('phoneInvalid');
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: size.height * 0.03),

                              // --- الـ BlocBuilder المحدث للزرار الرئيسي ---
                              BlocBuilder<LoginCubit, LoginState>(
                                buildWhen: (prev, curr) =>
                                    curr is LoginSendOTPLoading ||
                                    curr is LoginInitial ||
                                    curr is LoginError ||
                                    curr is LoginCodeSent ||
                                    curr is LoginResendCountdown ||
                                    curr is LoginResendEnabled,
                                builder: (context, state) {
                                  if (state is LoginSendOTPLoading) {
                                    return const CircularProgressIndicator(
                                      color: ColorManager.wasabi,
                                    );
                                  }

                                  // التحقق لو العداد شغال
                                  bool isCountdown =
                                      state is LoginResendCountdown;
                                  String btnLabel = context.tr('login');

                                  if (state is LoginResendCountdown) {
                                    // عرض الثواني المتبقية على الزرار نفسه
                                    btnLabel =
                                        "${context.tr('resendIn')} ${state.seconds}";
                                  }

                                  return CustButton(
                                    h: size.height,
                                    w: size.width,
                                    // لون باهت لو الزرار معطل
                                    color: isCountdown
                                        ? Colors.grey
                                        : ColorManager.wasabi,
                                    size: 'mid',
                                    lable: btnLabel,
                                    onTap: () {
                                      final cubit = context.read<LoginCubit>();

                                      if (_formKey.currentState!.validate()) {
                                        // لو العداد شغال والـ verificationId موجود، افتح الـ Sheet بس
                                        if (isCountdown &&
                                            cubit.verificationId != null) {
                                          _showOtpSheet(cubit.verificationId!);
                                        }
                                        // لو مفيش عداد، ابعت طلب جديد عادي
                                        else if (!isCountdown) {
                                          cubit.sendLoginOTP(
                                            _phoneController.text,
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),

                              const Spacer(flex: 2),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, Routes.signup),
                                child: Text(
                                  context.tr('dontHaveAccountSignUp'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
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
    );
  }
}
