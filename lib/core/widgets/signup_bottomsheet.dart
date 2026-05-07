import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_cubit.dart.dart'; // تأكد من المسار
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_state.dart';

class SignupBottomSheet {
  static Future<void> showOTP({
    required BuildContext context,
    required String phoneNumber,
    required SignUpCubit signUpCubit, // تغيير النوع هنا
    required Function(String smsCode) onVerify,
    required Function() onResend,
  }) {
    final TextEditingController otpController = TextEditingController();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        // نستخدم BlocProvider.value عشان نمرر الـ Cubit اللي موجود فعلاً
        return BlocProvider.value(
          value: signUpCubit,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الـ Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr('confirmAccount'),
                    style: TextStyleMangare.headingStyle.copyWith(
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${context.tr('enterCodeSentTo')} $phoneNumber",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 25),

                  // حقل إدخال الـ OTP
                  TextField(
                    controller: otpController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                      color: ColorManager.emeraldGreen,
                    ),
                    decoration: InputDecoration(
                      hintText: "------",
                      counterText: "",
                      filled: true,
                      fillColor: ColorManager.emeraldGreen.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // BlocBuilder لمتابعة عداد الـ SignUp
                  BlocBuilder<SignUpCubit, SignUpState>(
                    buildWhen: (prev, curr) =>
                        curr is SignUpResendCountdown ||
                        curr is SignUpResendEnabled ||
                        curr is SignUpInitial,
                    builder: (context, state) {
                      int seconds = 60;
                      bool canResend = false;

                      if (state is SignUpResendCountdown) {
                        seconds = state.seconds;
                      } else if (state is SignUpResendEnabled) {
                        canResend = true;
                      }

                      return Column(
                        children: [
                          Text(
                            canResend
                                ? context.tr('resendAvailable')
                                : "${context.tr('resendIn')} $seconds",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          TextButton(
                            onPressed: canResend ? onResend : null,
                            child: Text(
                              context.tr('resendCode'),
                              style: TextStyle(
                                color: canResend
                                    ? ColorManager.emeraldGreen
                                    : Colors.grey,
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

                  // زرار الـ Verify مع حالات الـ SignUp
                  BlocBuilder<SignUpCubit, SignUpState>(
                    builder: (context, state) {
                      if (state is SignUpLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: ColorManager.wasabi,
                          ),
                        );
                      }

                      return CustButton(
                        h: MediaQuery.of(context).size.height,
                        w: MediaQuery.of(context).size.width,
                        color: ColorManager.wasabi,
                        onTap: () {
                          if (otpController.text.length == 6) {
                            onVerify(otpController.text);
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
      },
    );
  }
}
