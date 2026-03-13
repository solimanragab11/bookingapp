import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/routes/routes.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/text_style_mangare.dart';
import 'package:remaking_booking_app_trail2/core/widgets/auth_bottomsheet.dart';
import 'package:remaking_booking_app_trail2/core/widgets/background.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_button.dart';
import 'package:remaking_booking_app_trail2/core/widgets/cust_textfiled.dart';
import 'package:remaking_booking_app_trail2/core/widgets/lang_button.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/login/bloc/login_states.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام الـ Screen Size كمرجع
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [const LanguageToggleButton()],
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          BackGround(h: screenHeight, w: screenWidth),
          BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginCodeSent) {
                AuthBottomSheet.showOTP(
                  context: context,
                  phoneNumber: _phoneController.text,
                  onVerify: (smsCode) {
                    context.read<LoginCubit>().verifyLoginOTP(
                      verificationId: state.verificationId,
                      smsCode: smsCode,
                    );
                  },
                );
              } else if (state is LoginError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr(state.message)),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is LoginSuccess) {
                if (Navigator.canPop(context)) Navigator.pop(context);
                Navigator.pushReplacementNamed(context, Routes.authWrapper);
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: LayoutBuilder(
                  // بيساعدنا نراقب القيود بتاعة الشاشة
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints
                              .maxHeight, // عشان العناصر تتوزع على كامل الشاشة
                        ),
                        child: IntrinsicHeight(
                          // بيخلي الـ Column ياخد حجمه الطبيعي جوه الـ Scroll
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center, // توسيط ديناميكي
                              children: [
                                SizedBox(height: screenHeight * 0.05),
                                // حجم الخط متناسب مع ارتفاع الشاشة
                                FittedBox(
                                  // بيمنع الـ Text من الخروج بره الشاشة لو الخط كبير
                                  child: Text(
                                    context.tr('appName'),
                                    style: TextStyleMangare.headingStyle
                                        .copyWith(
                                          fontSize: screenHeight * 0.065,
                                          color: ColorManager.wasabi,
                                        ),
                                  ),
                                ),
                                Text(
                                  context.tr('welcomeBack'),
                                  style: TextStyleMangare.headingStyle.copyWith(
                                    fontSize: screenHeight * 0.025,
                                  ),
                                ),

                                Spacer(
                                  flex: 1,
                                ), // فراغ مرن بيزيد ويقل حسب الشاشة

                                CustTextField(
                                  controller: _phoneController,
                                  hint: context.tr('phoneNumber'),
                                  icon: Icons.phone_android,
                                  isPhone: true,
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? context.tr('phoneRequired')
                                      : null,
                                ),

                                SizedBox(height: screenHeight * 0.03),

                                state is LoginSendOTPLoading
                                    ? const CircularProgressIndicator(
                                        color: ColorManager.wasabi,
                                      )
                                    : CustButton(
                                        h: screenHeight,
                                        w: screenWidth,
                                        color: ColorManager.wasabi,
                                        onTap: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context
                                                .read<LoginCubit>()
                                                .sendLoginOTP(
                                                  _phoneController.text,
                                                );
                                          }
                                        },
                                        size: "mid",
                                        lable: context.tr('login'),
                                      ),

                                Spacer(flex: 2), // فراغ أكبر في الأسفل

                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    Routes.signup,
                                  ),
                                  child: Text(
                                    context.tr('dontHaveAccountSignUp'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20), // أمان أخير من الأسفل
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
