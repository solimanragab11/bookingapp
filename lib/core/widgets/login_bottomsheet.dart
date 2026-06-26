import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/cust_button.dart';
import 'package:hanzbthalk/core/widgets/cust_textfiled.dart';
import 'package:hanzbthalk/core/widgets/snackbar_utils.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_wrapper_states.dart';
import 'package:hanzbthalk/features/auth/login/bloc/login_cubit.dart';
import 'package:hanzbthalk/features/auth/login/bloc/login_states.dart';

class AuthBottomSheet {
  static Future<void> showOTP({
    required BuildContext context,
    required String phoneNumber,
    required LoginCubit loginCubit,
    required Function(String smsCode) onVerify,
    required Function() onResend,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ضروري عشان الكيبورد ميتغطاش
      backgroundColor: Colors.transparent, // جعل الخلفية شفافة عشان الـ Container اللي جوه يظهر بـ Border
      builder: (bContext) {
        return BlocProvider.value(
          value: loginCubit,
          child: _LoginOtpSheet(
            phoneNumber: phoneNumber,
            loginCubit: loginCubit,
            onVerify: onVerify,
            onResend: onResend,
          ),
        );
      },
    );
  }

  static Future<void> showForgotPin({
    required BuildContext context,
    required AuthCubit authCubit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        return BlocProvider.value(
          value: authCubit,
          child: ForgotPinBottomSheet(authCubit: authCubit),
        );
      },
    );
  }
}

class _LoginOtpSheet extends StatefulWidget {
  final String phoneNumber;
  final LoginCubit loginCubit;
  final Function(String smsCode) onVerify;
  final Function() onResend;

  const _LoginOtpSheet({
    required this.phoneNumber,
    required this.loginCubit,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<_LoginOtpSheet> createState() => _LoginOtpSheetState();
}

class _LoginOtpSheetState extends State<_LoginOtpSheet> {
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ضبط الـ Padding ليتناسب مع ارتفاع الكيبورد
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: ColorManager.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
            top: BorderSide(
              color: ColorManager.emeraldGreen,
              width: 1.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorManager.emeraldGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('confirmAccount'),
                style: TextStyleMangare.headingStyle.copyWith(
                  fontSize: 22,
                  color: ColorManager.creasedKhaki,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${context.tr('enterCodeSentTo')} ${widget.phoneNumber}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: ColorManager.wasabi, fontSize: 14),
              ),
              const SizedBox(height: 25),

              TextField(
                controller: _otpController,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                onChanged: (value) {
                  final cleanVal = value.trim();
                  if (cleanVal.length == 6 && widget.loginCubit.state is! LoginLoading) {
                    widget.onVerify(cleanVal);
                  }
                },
                cursorColor: ColorManager.egyptianEarth,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "------",
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    letterSpacing: 8,
                  ),
                  counterText: "",
                  filled: true,
                  fillColor: ColorManager.noirDeVigne,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: ColorManager.emeraldGreen,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: ColorManager.egyptianEarth,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              BlocBuilder<LoginCubit, LoginState>(
                buildWhen: (prev, curr) =>
                    curr is LoginError ||
                    curr is LoginLoading ||
                    curr is LoginSuccess ||
                    curr is LoginCodeSent,
                builder: (context, state) {
                  if (state is LoginError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        context.tr(state.messageKey),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 15),

              BlocBuilder<LoginCubit, LoginState>(
                buildWhen: (prev, curr) =>
                    curr is LoginResendCountdown ||
                    curr is LoginResendEnabled ||
                    curr is LoginInitial ||
                    curr is LoginSendOTPLoading ||
                    (curr is LoginError && curr.messageKey == 'tooManyRequests'),
                builder: (context, state) {
                  int seconds = 60;
                  bool canResend = false;
                  bool isTooManyRequests = false;

                  if (state is LoginResendCountdown) {
                    seconds = state.seconds;
                  } else if (state is LoginResendEnabled) {
                    canResend = true;
                  } else if (state is LoginError && state.messageKey == 'tooManyRequests') {
                    isTooManyRequests = true;
                  }

                  return Column(
                    children: [
                      Text(
                        isTooManyRequests
                            ? context.tr('tooManyRequestsBlock')
                            : (canResend
                                ? context.tr('resendAvailable')
                                : "${context.tr('resendIn')} $seconds"),
                        style: TextStyle(
                          fontSize: 13,
                          color: isTooManyRequests
                              ? Colors.redAccent
                              : ColorManager.wasabi,
                        ),
                      ),
                      TextButton(
                        onPressed: (canResend && !isTooManyRequests) ? widget.onResend : null,
                        child: Text(
                          context.tr('resendCode'),
                          style: TextStyle(
                            color: (canResend && !isTooManyRequests)
                                ? ColorManager.egyptianEarth
                                : Colors.white.withOpacity(0.3),
                            fontWeight: FontWeight.bold,
                            decoration: (canResend && !isTooManyRequests)
                                ? TextDecoration.underline
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 15),

              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorManager.egyptianEarth,
                      ),
                    );
                  }

                  return CustButton(
                    h: MediaQuery.of(context).size.height,
                    w: MediaQuery.of(context).size.width,
                    color: ColorManager.egyptianEarth,
                    onTap: () {
                      if (_otpController.text.length == 6) {
                        widget.onVerify(_otpController.text);
                      }
                    },
                    size: "mid",
                    lable: context.tr('verifyCodeBtn'),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPinBottomSheet extends StatefulWidget {
  final AuthCubit authCubit;

  const ForgotPinBottomSheet({super.key, required this.authCubit});

  @override
  State<ForgotPinBottomSheet> createState() => _ForgotPinBottomSheetState();
}

class _ForgotPinBottomSheetState extends State<ForgotPinBottomSheet> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpSent) {
          setState(() {
            _verificationId = state.verificationId;
          });
          SnackBarUtils.showSuccess(context, 'codeSentSuccess');
        } else if (state is AuthResetPinSuccess) {
          SnackBarUtils.showSuccess(context, 'pinResetSuccess');
          Navigator.of(context).pop();
        } else if (state is AuthFailure) {
          SnackBarUtils.showError(context, state.messageKey);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: ColorManager.cardSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              border: Border(
                top: BorderSide(
                  color: ColorManager.emeraldGreen,
                  width: 1.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ColorManager.emeraldGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('resetPinBtn'),
                      style: TextStyleMangare.headingStyle.copyWith(
                        fontSize: 22,
                        color: ColorManager.creasedKhaki,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustTextField(
                      controller: _phoneController,
                      hint: context.tr('phoneNumber'),
                      icon: Icons.phone_android,
                      isPhone: true,
                      enabled: _verificationId == null && !isLoading,
                      textColor: Colors.white,
                      hintTextColor: Colors.white.withOpacity(0.4),
                      iconColor: ColorManager.wasabi,
                      fillColor: ColorManager.noirDeVigne,
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
                    const SizedBox(height: 15),
                    if (_verificationId != null) ...[
                      CustTextField(
                        controller: _otpController,
                        hint: context.tr('confirmAccount'),
                        icon: Icons.lock_outline,
                        textColor: Colors.white,
                        hintTextColor: Colors.white.withOpacity(0.4),
                        iconColor: ColorManager.wasabi,
                        fillColor: ColorManager.noirDeVigne,
                        enabledBorderColor: ColorManager.emeraldGreen,
                        focusedBorderColor: ColorManager.egyptianEarth,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr('fieldRequired');
                          }
                          if (value.trim().length != 6) {
                            return context.tr('invalid_otp');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustTextField(
                        controller: _pinController,
                        hint: context.tr('enterNewPin'),
                        icon: Icons.password,
                        textColor: Colors.white,
                        hintTextColor: Colors.white.withOpacity(0.4),
                        iconColor: ColorManager.wasabi,
                        fillColor: ColorManager.noirDeVigne,
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
                      const SizedBox(height: 15),
                      CustTextField(
                        controller: _confirmPinController,
                        hint: context.tr('confirmNewPin'),
                        icon: Icons.password,
                        textColor: Colors.white,
                        hintTextColor: Colors.white.withOpacity(0.4),
                        iconColor: ColorManager.wasabi,
                        fillColor: ColorManager.noirDeVigne,
                        enabledBorderColor: ColorManager.emeraldGreen,
                        focusedBorderColor: ColorManager.egyptianEarth,
                        keyboardType: TextInputType.number,
                        isPassword: true,
                        maxLength: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr('pinRequired');
                          }
                          if (value.trim() != _pinController.text.trim()) {
                            return context.tr('pinsDoNotMatch');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    CustButton(
                      h: size.height,
                      w: size.width,
                      color: ColorManager.egyptianEarth,
                      size: 'mid',
                      lable: _verificationId == null
                          ? context.tr('confirm')
                          : context.tr('resetPinBtn'),
                      isLoading: isLoading,
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          if (_verificationId == null) {
                            widget.authCubit.sendResetPinOTP(
                              phoneNumber: _phoneController.text.trim(),
                              onCodeSent: (_) {},
                              onError: (_) {},
                            );
                          } else {
                            widget.authCubit.resetPin(
                              verificationId: _verificationId!,
                              smsCode: _otpController.text.trim(),
                              phoneNumber: _phoneController.text.trim(),
                              newPin: _pinController.text.trim(),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
