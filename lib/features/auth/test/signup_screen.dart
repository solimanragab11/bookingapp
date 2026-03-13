import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remaking_booking_app_trail2/features/auth/test/hanzbthalk_theme.dart';
import 'package:remaking_booking_app_trail2/features/auth/test/signup_cubit.dart';
import 'package:remaking_booking_app_trail2/features/auth/test/signup_widgets.dart';

/// ---------------------------------------------------------------------------
/// SignupScreen — Root entry point
///
/// Folder:  lib/features/auth/signup/ui/screens/
///
/// Usage:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => BlocProvider(
///       create: (_) => SignupCubit(),
///       child: const SignupScreen(),
///     ),
///   ));
/// ---------------------------------------------------------------------------
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: HanzbthalkTheme.deepNoir,
      ),
      child: Scaffold(
        backgroundColor: HanzbthalkTheme.deepNoir,
        body: BlocConsumer<SignupCubitTest, SignupState>(
          listener: _handleStateListener,
          builder: (context, state) {
            return Stack(
              children: [
                // ── Background cinematic gradient ──
                const _CinematicBackground(),

                // ── Main scrollable content ──
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        const HanzbthalkBrandHeader(),
                        const SizedBox(height: 48),

                        // ── Animated stage transition ──
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(0.06, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            ),
                          ),
                          child: _buildStageContent(context, state),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  Stage router
  // ─────────────────────────────────────────────────────
  Widget _buildStageContent(BuildContext context, SignupState state) {
    if (state is SignupOtpSent ||
        state is SignupVerifyingOtp ||
        state is SignupOtpTimeout ||
        (state is SignupError &&
            (state.type == SignupErrorType.otpInvalid ||
                state.type == SignupErrorType.otpExpired))) {
      return _OtpStage(key: const ValueKey('otp_stage'), state: state);
    }

    return _PhoneStage(key: const ValueKey('phone_stage'), state: state);
  }

  // ─────────────────────────────────────────────────────
  //  Global state listener (navigation / toasts)
  // ─────────────────────────────────────────────────────
  void _handleStateListener(BuildContext context, SignupState state) {
    if (state is SignupSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Verified! Welcome to Hanzbthalk 🎉'),
          backgroundColor: HanzbthalkTheme.wasabiGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      // TODO: Replace with your actual navigation:
      // context.go('/home');
    }
  }
}

// ============================================================================
//  Phone Input Stage
// ============================================================================
class _PhoneStage extends StatefulWidget {
  final SignupState state;
  const _PhoneStage({super.key, required this.state});

  @override
  State<_PhoneStage> createState() => _PhoneStageState();
}

class _PhoneStageState extends State<_PhoneStage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isLoading => widget.state is SignupSendingOtp;

  bool get _termsAccepted =>
      widget.state is SignupInitial &&
      (widget.state as SignupInitial).termsAccepted;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignupCubitTest>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Stage label ──
          Text('Create Account', style: HanzbthalkTheme.headline),
          const SizedBox(height: 6),
          Text(
            'Enter your Egyptian mobile number to get started.',
            style: HanzbthalkTheme.caption.copyWith(fontSize: 13.5),
          ),

          const SizedBox(height: 32),

          // ── Phone number input ──
          GlassInputField(
            controller: _phoneController,
            hint: '01X XXXX XXXX',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            prefix: Padding(
              padding: const EdgeInsets.only(left: 14, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇪🇬', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    '+20',
                    style: HanzbthalkTheme.body.copyWith(
                      color: HanzbthalkTheme.muted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 1,
                    height: 20,
                    color: HanzbthalkTheme.glassBorder,
                  ),
                ],
              ),
            ),
            validator: (v) {
              final phone = v?.trim() ?? '';
              if (phone.isEmpty) return 'Phone number is required.';
              final pattern = RegExp(r'^01[0125]\d{8}$');
              if (!pattern.hasMatch(phone)) {
                return 'Enter a valid Egyptian number (01XXXXXXXXX).';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // ── Terms ──
          TermsCheckbox(
            value: _termsAccepted,
            onChanged: (v) => cubit.toggleTerms(accepted: v ?? false),
          ),

          const SizedBox(height: 10),

          // ── Error banner ──
          if (widget.state is SignupError &&
              (widget.state as SignupError).type !=
                  SignupErrorType.otpInvalid &&
              (widget.state as SignupError).type !=
                  SignupErrorType.otpExpired) ...[
            ErrorBanner(message: (widget.state as SignupError).message),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 12),

          // ── CTA Button ──
          WasabiButton(
            label: 'Send Verification Code',
            icon: Icons.send_rounded,
            isLoading: _isLoading,
            onTap: _termsAccepted && !_isLoading
                ? () {
                    if (_formKey.currentState?.validate() ?? false) {
                      cubit.sendOtp(_phoneController.text.trim());
                    }
                  }
                : null,
          ),

          const SizedBox(height: 28),
          const LabeledDivider(label: 'Already have an account?'),
          const SizedBox(height: 16),

          // ── Sign in link ──
          GestureDetector(
            onTap: () {
              // TODO: Navigate to sign-in
            },
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: HanzbthalkTheme.body.copyWith(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Sign in ',
                      style: TextStyle(color: HanzbthalkTheme.offWhite),
                    ),
                    TextSpan(
                      text: 'here',
                      style: const TextStyle(
                        color: HanzbthalkTheme.wasabiGreenLight,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: HanzbthalkTheme.wasabiGreenLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  OTP Verification Stage
// ============================================================================
class _OtpStage extends StatefulWidget {
  final SignupState state;
  const _OtpStage({super.key, required this.state});

  @override
  State<_OtpStage> createState() => _OtpStageState();
}

class _OtpStageState extends State<_OtpStage> {
  String _currentOtp = '';

  bool get _isLoading => widget.state is SignupVerifyingOtp;

  String get _phoneLabel {
    if (widget.state is SignupOtpSent) {
      return (widget.state as SignupOtpSent).phoneNumber;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SignupCubitTest>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Back button ──
        GestureDetector(
          onTap: cubit.reset,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: HanzbthalkTheme.muted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Change number',
                style: HanzbthalkTheme.caption.copyWith(
                  color: HanzbthalkTheme.muted,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── OTP icon ──
        Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: HanzbthalkTheme.wasabiGreen.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: HanzbthalkTheme.wasabiGreen.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: HanzbthalkTheme.wasabiGreenLight,
              size: 28,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Verify Your Number',
          style: HanzbthalkTheme.headline,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to\n$_phoneLabel',
          style: HanzbthalkTheme.caption.copyWith(fontSize: 13.5, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 36),

        // ── OTP boxes ──
        OtpInputRow(
          enabled: !_isLoading,
          onCompleted: (otp) => setState(() => _currentOtp = otp),
        ),

        const SizedBox(height: 14),

        // ── Error banner ──
        if (widget.state is SignupError) ...[
          const SizedBox(height: 4),
          ErrorBanner(message: (widget.state as SignupError).message),
          const SizedBox(height: 4),
        ],

        if (widget.state is SignupOtpTimeout) ...[
          const SizedBox(height: 4),
          ErrorBanner(
            message: 'Auto-retrieval timed out. Enter the code manually.',
          ),
          const SizedBox(height: 4),
        ],

        const SizedBox(height: 28),

        // ── Verify Button ──
        WasabiButton(
          label: 'Verify & Continue',
          icon: Icons.verified_rounded,
          isLoading: _isLoading,
          onTap: _currentOtp.length == 6 && !_isLoading
              ? () => cubit.verifyOtp(_currentOtp)
              : null,
        ),

        const SizedBox(height: 20),

        // ── Resend ──
        Center(
          child: _ResendTimer(
            onResend: () {
              // Re-navigate triggers resend with stored phone
              cubit.reset();
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
//  Resend countdown timer
// ============================================================================
class _ResendTimer extends StatefulWidget {
  final VoidCallback onResend;
  const _ResendTimer({required this.onResend});

  @override
  State<_ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<_ResendTimer> {
  int _seconds = 60;
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(
      const Duration(seconds: 1),
      (i) => 59 - i,
    ).take(60);
    _ticker.listen((s) {
      if (mounted) setState(() => _seconds = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_seconds > 0) {
      return Text(
        'Resend code in 0:${_seconds.toString().padLeft(2, '0')}',
        style: HanzbthalkTheme.caption.copyWith(fontSize: 13),
      );
    }
    return GestureDetector(
      onTap: widget.onResend,
      child: Text(
        'Didn\'t receive it? Resend code',
        style: HanzbthalkTheme.caption.copyWith(
          fontSize: 13,
          color: HanzbthalkTheme.wasabiGreenLight,
          decoration: TextDecoration.underline,
          decorationColor: HanzbthalkTheme.wasabiGreenLight,
        ),
      ),
    );
  }
}

// ============================================================================
//  Cinematic background (grain + gradient)
// ============================================================================
class _CinematicBackground extends StatelessWidget {
  const _CinematicBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          // Top radial glow — Wasabi
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HanzbthalkTheme.wasabiGreen.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom radial glow — Egyptian Earth
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HanzbthalkTheme.egyptianEarth.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
