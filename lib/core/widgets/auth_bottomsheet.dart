import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';

class AuthBottomSheet {
  static void showOTP({
    required BuildContext context,
    required String phoneNumber,
    required Function(String smsCode)
    onVerify, // الدالة اللي هتتنفذ لما يدوس تأكيد
  }) {
    final TextEditingController otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (bContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // الخط اللي فوق (Handle)
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
                  style: TextStyleMangare.headingStyle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  "${context.tr('enterCodeSentTo')} $phoneNumber",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),
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
                const SizedBox(height: 25),
                CustButton(
                  h: MediaQuery.of(context).size.height,
                  w: MediaQuery.of(context).size.width,
                  color: ColorManager.wasabi,
                  onTap: () {
                    if (otpController.text.length == 6) {
                      onVerify(
                        otpController.text,
                      ); // بنرجع الكود للي نادى الدالة
                    }
                  },
                  size: "mid",
                  lable: context.tr('verifyCodeBtn'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
