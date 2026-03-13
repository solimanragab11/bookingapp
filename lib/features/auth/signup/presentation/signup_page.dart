import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';
import 'package:remaking_booking_app_trail2/core/widgets/auth_bottomsheet.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_textfiled.dart';
import 'package:remaking_booking_app_trail2/core/widgets/lang_button.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/cubit/signup_cubit.dart.dart';
import 'package:remaking_booking_app_trail2/features/auth/signup/statues/signup_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [const LanguageToggleButton()],
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            BackGround(h: size.height, w: size.width),
            SafeArea(
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
                            children: [
                              SizedBox(height: size.height * 0.05),
                              FittedBox(
                                child: Text(
                                  context.tr('appName'),
                                  style: TextStyleMangare.headingStyle.copyWith(
                                    fontSize: size.height * 0.06,
                                    color: ColorManager.wasabi,
                                  ),
                                ),
                              ),
                              Text(
                                context.tr('signup'),
                                style: TextStyleMangare.headingStyle.copyWith(
                                  fontSize: size.height * 0.025,
                                  color: ColorManager.cardSurface,
                                ),
                              ),
                              const Spacer(flex: 1),
                              CustTextField(
                                controller: nameController,
                                hint: context.tr('fullName'),
                                icon: Icons.person_outline,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? context.tr('nameRequired')
                                    : null,
                              ),
                              SizedBox(height: size.height * 0.02),
                              CustTextField(
                                controller: phoneController,
                                hint: context.tr('phoneNumber'),
                                icon: Icons.phone_android,
                                isPhone: true,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? context.tr('phoneRequired')
                                    : null,
                              ),
                              const Spacer(flex: 1),
                              BlocConsumer<SignUpCubit, SignUpState>(
                                listener: (context, state) {
                                  if (state is CodeSentState) {
                                    AuthBottomSheet.showOTP(
                                      context: context,
                                      phoneNumber: phoneController.text,
                                      onVerify: (smsCode) {
                                        context.read<SignUpCubit>().verifyOTP(
                                          smsCode: smsCode,
                                          username: nameController.text,
                                        );
                                      },
                                    );
                                  } else if (state is SignUpSuccess) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  } else if (state is SignUpError) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.tr(state.errorMessage),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  if (state is SignUpLoading) {
                                    return const CircularProgressIndicator(
                                      color: ColorManager.wasabi,
                                    );
                                  }
                                  return CustButton(
                                    h: size.height,
                                    w: size.width,
                                    color: ColorManager.wasabi,
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        context.read<SignUpCubit>().sendOTP(
                                          phoneController.text,
                                        );
                                      }
                                    },
                                    size: "mid",
                                    lable: context.tr('confirm'),
                                  );
                                },
                              ),
                              const Spacer(flex: 2),
                              TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                ),
                                child: Text(
                                  context.tr('youAlreadyHaveAccountLogin'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}
