import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/cust_button.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_cubit.dart';
import 'package:hanzbthalk/features/auth/auth_wrapper/auth_wrapper_states.dart';

class SignupBottomSheet {
  static Future<void> showOTP({
    required BuildContext context,
    required String phoneNumber,
    required AuthCubit authCubit,
    required Function(String smsCode) onVerify,
    required Function() onResend,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        return BlocProvider.value(
          value: authCubit,
          child: _SignUpOtpSheet(
            phoneNumber: phoneNumber,
            authCubit: authCubit,
            onVerify: onVerify,
            onResend: onResend,
          ),
        );
      },
    );
  }
}

class _SignUpOtpSheet extends StatefulWidget {
  final String phoneNumber;
  final AuthCubit authCubit;
  final Function(String smsCode) onVerify;
  final Function() onResend;

  const _SignUpOtpSheet({
    required this.phoneNumber,
    required this.authCubit,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<_SignUpOtpSheet> createState() => _SignUpOtpSheetState();
}

class _SignUpOtpSheetState extends State<_SignUpOtpSheet> {
  late final TextEditingController _otpController;
  Timer? _resendTimer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _remainingSeconds = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: ColorManager.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(
            top: BorderSide(color: ColorManager.emeraldGreen, width: 1.5),
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
                style: const TextStyle(
                  color: ColorManager.wasabi,
                  fontSize: 14,
                ),
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
                  if (cleanVal.length == 6 &&
                      widget.authCubit.state is! AuthLoading) {
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
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (prev, curr) =>
                    curr is AuthFailure ||
                    curr is AuthLoading ||
                    curr is AuthSuccess ||
                    curr is AuthOtpSent,
                builder: (context, state) {
                  if (state is AuthFailure) {
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

              Builder(
                builder: (context) {
                  final canResend = _remainingSeconds == 0;
                  return Column(
                    children: [
                      Text(
                        canResend
                            ? context.tr('resendAvailable')
                            : "${context.tr('resendIn')} $_remainingSeconds",
                        style: const TextStyle(
                          fontSize: 13,
                          color: ColorManager.wasabi,
                        ),
                      ),
                      TextButton(
                        onPressed: canResend
                            ? () {
                                widget.onResend();
                                _startResendTimer();
                              }
                            : null,
                        child: Text(
                          context.tr('resendCode'),
                          style: TextStyle(
                            color: canResend
                                ? ColorManager.egyptianEarth
                                : Colors.white.withOpacity(0.3),
                            fontWeight: FontWeight.bold,
                            decoration: canResend
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

              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
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
