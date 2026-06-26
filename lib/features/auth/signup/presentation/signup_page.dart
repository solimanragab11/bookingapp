import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/cust_button.dart';
import 'package:hanzbthalk/core/widgets/cust_textfiled.dart';
import 'package:hanzbthalk/core/widgets/lang_button.dart';
import 'package:hanzbthalk/core/widgets/signup_bottomsheet.dart';
import 'package:hanzbthalk/core/widgets/brand_logo.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_wrapper_states.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Prevents opening the OTP sheet twice on rapid state changes.
  bool _otpSheetOpen = false;
  String? _currentVerificationId;

  // Policies agreement flag
  bool _agreedToPolicies = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // OTP bottom sheet
  // ---------------------------------------------------------------------------

  void _showOtpSheet(String verificationId) {
    _currentVerificationId = verificationId;
    if (_otpSheetOpen) return;
    _otpSheetOpen = true;

    final authCubit = context.read<AuthCubit>();

    SignupBottomSheet.showOTP(
      context: context,
      phoneNumber: _phoneController.text,
      authCubit: authCubit,
      onResend: () {
        authCubit.sendSignUpOTP(
          phoneNumber: _phoneController.text,
          onCodeSent: (_) {},
          onError: (_) {},
        );
      },
      onVerify: (smsCode) {
        authCubit.signUpWithPhoneAndPin(
          verificationId: _currentVerificationId ?? verificationId,
          smsCode: smsCode,
          username: _nameController.text,
          role: 'user',
          pin: _pinController.text.trim(),
          phoneNumber: _phoneController.text,
        );
      },
    ).then((_) {
      _otpSheetOpen = false;
    });
  }

  Future<void> _launchPolicyUrl() async {
    final Uri url = Uri.parse('https://hanzbthalk-aa12c.web.app/terms');
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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                if (state is AuthOtpSent) {
                  _currentVerificationId = state.verificationId;
                  _showOtpSheet(state.verificationId);
                } else if (state is AuthSuccess) {
                  _otpSheetOpen = false;
                  Navigator.pushReplacementNamed(context, Routes.authWrapper);
                } else if (state is AuthFailure) {
                  if (!_otpSheetOpen && state.messageKey != 'networkError') {
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
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 0.05),
                                BrandLogo(fontSize: size.height * 0.065),
                                Text(
                                  context.tr('signup'),
                                  style: TextStyleMangare.headingStyle.copyWith(
                                    fontSize: size.height * 0.025,
                                    color: ColorManager.creasedKhaki,
                                  ),
                                ),
                                const Spacer(),
                                CustTextField(
                                  controller: _nameController,
                                  hint: context.tr('fullName'),
                                  icon: Icons.person_outline,
                                  textColor: Colors.white,
                                  hintTextColor: Colors.white.withOpacity(0.4),
                                  iconColor: ColorManager.wasabi,
                                  fillColor: ColorManager.cardSurface,
                                  enabledBorderColor: ColorManager.emeraldGreen,
                                  focusedBorderColor:
                                      ColorManager.egyptianEarth,
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
                                  textColor: Colors.white,
                                  hintTextColor: Colors.white.withOpacity(0.4),
                                  iconColor: ColorManager.wasabi,
                                  fillColor: ColorManager.cardSurface,
                                  enabledBorderColor: ColorManager.emeraldGreen,
                                  focusedBorderColor:
                                      ColorManager.egyptianEarth,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return context.tr('phoneRequired');
                                    }
                                    if (v.trim().length < 11) {
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
                                  focusedBorderColor:
                                      ColorManager.egyptianEarth,
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
                                SizedBox(height: size.height * 0.02),
                                CustTextField(
                                  controller: _confirmPinController,
                                  hint: context.tr('confirmNewPin'),
                                  icon: Icons.lock_outline,
                                  textColor: Colors.white,
                                  hintTextColor: Colors.white.withOpacity(0.4),
                                  iconColor: ColorManager.wasabi,
                                  fillColor: ColorManager.cardSurface,
                                  enabledBorderColor: ColorManager.emeraldGreen,
                                  focusedBorderColor:
                                      ColorManager.egyptianEarth,
                                  keyboardType: TextInputType.number,
                                  isPassword: true,
                                  maxLength: 6,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return context.tr('pinRequired');
                                    }
                                    if (value.trim() !=
                                        _pinController.text.trim()) {
                                      return context.tr('pinsDoNotMatch');
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: size.height * 0.02),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _agreedToPolicies,
                                      activeColor: ColorManager.egyptianEarth,
                                      checkColor: Colors.white,
                                      side: const BorderSide(
                                        color: ColorManager.wasabi,
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _agreedToPolicies = val ?? false;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _launchPolicyUrl,
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: size.width * 0.035,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${context.tr('iAgreeTo')} ',
                                              ),
                                              TextSpan(
                                                text: context.tr(
                                                  'privacyPolicyAndTerms',
                                                ),
                                                style: const TextStyle(
                                                  color: ColorManager
                                                      .egyptianEarth,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;

                                    return CustButton(
                                      h: size.height,
                                      w: size.width,
                                      color: ColorManager.egyptianEarth,
                                      size: 'mid',
                                      lable: context.tr('confirm'),
                                      isLoading: isLoading,
                                      onTap: () {
                                        final cubit = context.read<AuthCubit>();

                                        if (_formKey.currentState!.validate()) {
                                          if (!_agreedToPolicies) {
                                            SnackBarUtils.showError(
                                              context,
                                              'mustAgreeToPolicies',
                                            );
                                            return;
                                          }
                                          cubit.sendSignUpOTP(
                                            phoneNumber: _phoneController.text
                                                .trim(),
                                            onCodeSent: (_) {},
                                            onError: (_) {},
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
                                      color: ColorManager.creasedKhaki,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _launchPolicyUrl,
                                  child: Text(
                                    context.tr('visitWebsite'),
                                    style: const TextStyle(
                                      color: ColorManager.wasabi,
                                      decoration: TextDecoration.underline,
                                      fontSize: 14,
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
