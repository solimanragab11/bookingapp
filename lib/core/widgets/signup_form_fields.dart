import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/routes/routes.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class SignUpFormFields extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function(String?) onFullNameSaved;
  final Function(String?) onEmailSaved;
  final Function(String?) onPasswordSaved;
  final Function(String?) onPhoneNumberSaved;
  final VoidCallback onSignUpPressed;
  final bool isLoading;
  final String? statusMessage;
  final Color statusColor;

  const SignUpFormFields({
    super.key,
    required this.formKey,
    required this.onFullNameSaved,
    required this.onEmailSaved,
    required this.onPasswordSaved,
    required this.onSignUpPressed,
    required this.onPhoneNumberSaved,
    required this.isLoading,
    this.statusMessage,
    this.statusColor = Colors.transparent,
  });

  Widget _buildInputField(
    BuildContext context,
    String label,
    String hint,
    Function(String?) onSaved, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(bottom: h * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ColorManager.wasabi,
              fontSize: w * 0.038,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: h * 0.008),
          TextFormField(
            onSaved: onSaved,
            obscureText: isPassword,
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '${AppLocalizations.of(context)!.translate('Pleaseenteryour')} $label';
              }
              if (isPassword && value.length < 8) {
                return AppLocalizations.of(
                  context,
                )!.translate('passwordMinLength');
              }
              if (isEmail && !value.contains('@')) {
                return AppLocalizations.of(
                  context,
                )!.translate('enterValidEmail');
              }
              return null;
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: w * 0.035,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
                vertical: h * 0.018,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: ColorManager.wasabi),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.all(w * 0.08),
          decoration: BoxDecoration(
            color: ColorManager.cardSurface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              // عشان الكيبورد ميعملش Overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context)!.translate('JointheHub'),
                    style: TextStyle(
                      fontSize: w * 0.075,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: h * 0.005),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.translate('Signuptounlockallbookingopportunities.'),
                    style: TextStyle(
                      fontSize: w * 0.035,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: h * 0.03),

                  _buildInputField(
                    context,
                    AppLocalizations.of(context)!.translate('FullName'),
                    'Jane Doe',
                    onFullNameSaved,
                  ),
                  _buildInputField(
                    context,
                    AppLocalizations.of(context)!.translate('EmailAddress'),
                    'you@example.com',
                    onEmailSaved,
                    isEmail: true,
                  ),
                  _buildInputField(
                    context,
                    AppLocalizations.of(context)!.translate('Password'),
                    AppLocalizations.of(
                      context,
                    )!.translate('Minimum8characters'),
                    onPasswordSaved,
                    isPassword: true,
                  ),
                  _buildInputField(
                    context,
                    AppLocalizations.of(context)!.translate('phoneNumber'),
                    '01xxxxxxxxx',
                    onPhoneNumberSaved,
                  ),

                  const SizedBox(height: 10),

                  // زرار الـ Sign Up المطور
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onSignUpPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.wasabi,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: h * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: w * 0.045,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  if (statusMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Center(
                        child: Text(
                          statusMessage!,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: h * 0.02),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, Routes.login),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.translate('YouAlreadyHaveAccount? Log In'),
                        style: const TextStyle(
                          color: ColorManager.wasabi,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
