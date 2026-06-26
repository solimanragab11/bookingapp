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
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_wrapper_states.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _appVersion = '';

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
    _pinController.dispose();
    super.dispose();
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
          BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                if (Navigator.canPop(context)) Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.authWrapper);
              } else if (state is AuthFailure) {
                if (state.messageKey != 'networkError') {
                  SnackBarUtils.showError(context, state.messageKey);
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
                              SizedBox(height: size.height * 0.02),
                              CustTextField(
                                controller: _pinController,
                                hint: context.tr('pin'),
                                icon: Icons.lock_outline,
                                textColor: Colors.white,
                                hintTextColor: Colors.white.withOpacity(0.4),
                                iconColor: ColorManager.wasabi,
                                fillColor: ColorManager.cardSurface,
                                enabledBorderColor: ColorManager.emeraldGreen,
                                focusedBorderColor: ColorManager.egyptianEarth,
                                keyboardType: TextInputType.number,
                                isPassword: true,
                                maxLength: 6,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.tr('pinRequired');
                                  }
                                  if (value.trim().length != 6) {
                                    return context.tr('pinInvalid');
                                  }
                                  return null;
                                },
                              ),
                              // Forgot PIN text button
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    AuthBottomSheet.showForgotPin(
                                      context: context,
                                      authCubit: context.read<AuthCubit>(),
                                    );
                                  },
                                  child: Text(
                                    context.tr('forgotPin'),
                                    style: const TextStyle(
                                      color: ColorManager.creasedKhaki,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),

                              // --- الـ BlocBuilder المحدث للزرار الرئيسي ---
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;

                                  return CustButton(
                                    h: size.height,
                                    w: size.width,
                                    color: ColorManager.egyptianEarth,
                                    size: 'mid',
                                    lable: context.tr('login'),
                                    isLoading: isLoading,
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<AuthCubit>().loginWithPhoneAndPin(
                                          phoneNumber: _phoneController.text.trim(),
                                          pin: _pinController.text.trim(),
                                        );
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
