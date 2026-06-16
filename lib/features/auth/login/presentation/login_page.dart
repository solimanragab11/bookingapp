// top of page change:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/login_bottomsheet.dart';
import 'package:hanzbthalk/core/widgets/cust_button.dart';
import 'package:hanzbthalk/core/widgets/cust_textfiled.dart';
import 'package:hanzbthalk/core/widgets/lang_button.dart';
import 'package:hanzbthalk/core/widgets/brand_logo.dart';
import 'package:hanzbthalk/features/auth/login/bloc/login_cubit.dart';
import 'package:hanzbthalk/features/auth/login/bloc/login_states.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _appVersion = '';

  // Flag لمنع تكرار فتح الـ BottomSheet
  // ignore: unused_field
  bool _otpSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (e) {
      debugPrint('Error getting package info: $e');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // OTP bottom sheet logic
  // ---------------------------------------------------------------------------
  void _showOtpSheet(String verificationId) {
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
      _otpSheetOpen = false;
    });
  }

  Future<void> _launchWebsiteUrl() async {
    final Uri url = Uri.parse('https://hanzbthalk-aa12c.web.app/');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching url: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColorManager.noirDeVigne,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: const [LanguageToggleButton()],
      ),
      body: Stack(
        children: [
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginCodeSent) {
                _showOtpSheet(state.verificationId);
              } else if (state is LoginSuccess) {
                _otpSheetOpen = false;
                if (Navigator.canPop(context)) Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.authWrapper);
              } else if (state is LoginError) {
                if (!_otpSheetOpen) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(context.tr(state.messageKey)),
                        backgroundColor: Colors.red,
                      ),
                    );
                }
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
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: size.height * 0.05),
                              BrandLogo(fontSize: size.height * 0.065),
                              Text(
                                context.tr('welcomeBack'),
                                style: TextStyleMangare.headingStyle.copyWith(
                                  fontSize: size.height * 0.025,
                                  color: ColorManager.creasedKhaki,
                                ),
                              ),
                              const Spacer(),
                              CustTextField(
                                controller: _phoneController,
                                hint: context.tr('phoneNumber'),
                                icon: Icons.phone_android,
                                isPhone: true,
                                textColor: Colors.white,
                                hintTextColor: Colors.white.withOpacity(0.4),
                                iconColor: ColorManager.wasabi,
                                fillColor: ColorManager.cardSurface,
                                enabledBorderColor: ColorManager.emeraldGreen,
                                focusedBorderColor: ColorManager.egyptianEarth,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.tr('phoneRequired');
                                  }
                                  if (value.trim().length < 11) {
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
                                  final isLoading =
                                      state is LoginSendOTPLoading;
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
                                        : ColorManager.egyptianEarth,
                                    size: 'mid',
                                    lable: btnLabel,
                                    isLoading: isLoading,
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
                                    color: ColorManager.creasedKhaki,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _launchWebsiteUrl,
                                child: Text(
                                  context.tr('visitWebsite'),
                                  style: const TextStyle(
                                    color: ColorManager.wasabi,
                                    decoration: TextDecoration.underline,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (_appVersion.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  '${context.tr('version')} $_appVersion',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
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
