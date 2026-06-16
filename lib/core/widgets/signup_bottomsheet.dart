import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';
import 'package:hanzbthalk/core/widgets/cust_button.dart';
import 'package:hanzbthalk/features/auth/signup/cubit/signup_cubit.dart.dart'; // تأكد من المسار
import 'package:hanzbthalk/features/auth/signup/cubit/signup_state.dart';

class SignupBottomSheet {
  static Future<void> showOTP({
    required BuildContext context,
    required String phoneNumber,
    required SignUpCubit signUpCubit, // تغيير النوع هنا
    required Function(String smsCode) onVerify,
    required Function() onResend,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        // نستخدم BlocProvider.value عشان نمرر الـ Cubit اللي موجود فعلاً
        return BlocProvider.value(
          value: signUpCubit,
          child: _SignUpOtpSheet(
            phoneNumber: phoneNumber,
            signUpCubit: signUpCubit,
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
  final SignUpCubit signUpCubit;
  final Function(String smsCode) onVerify;
  final Function() onResend;

  const _SignUpOtpSheet({
    required this.phoneNumber,
    required this.signUpCubit,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<_SignUpOtpSheet> createState() => _SignUpOtpSheetState();
}

class _SignUpOtpSheetState extends State<_SignUpOtpSheet> {
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
                    widget.signUpCubit.state is! SignUpLoading) {
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
            BlocBuilder<SignUpCubit, SignUpState>(
              buildWhen: (prev, curr) =>
                  curr is SignUpError ||
                  curr is SignUpLoading ||
                  curr is SignUpSuccess ||
                  curr is SignUpCodeSent,
              builder: (context, state) {
                if (state is SignUpError) {
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

            BlocBuilder<SignUpCubit, SignUpState>(
              buildWhen: (prev, curr) =>
                  curr is SignUpResendCountdown ||
                  curr is SignUpResendEnabled ||
                  curr is SignUpInitial ||
                  curr is SignUpLoading ||
                  (curr is SignUpError &&
                      curr.messageKey == 'tooManyRequests'),
              builder: (context, state) {
                int seconds = 60;
                bool canResend = false;
                bool isTooManyRequests = false;

                if (state is SignUpResendCountdown) {
                  seconds = state.seconds;
                } else if (state is SignUpResendEnabled) {
                  canResend = true;
                } else if (state is SignUpError &&
                    state.messageKey == 'tooManyRequests') {
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
                      onPressed: (canResend && !isTooManyRequests)
                          ? widget.onResend
                          : null,
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

            BlocBuilder<SignUpCubit, SignUpState>(
              builder: (context, state) {
                if (state is SignUpLoading) {
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
    );
  }
}
