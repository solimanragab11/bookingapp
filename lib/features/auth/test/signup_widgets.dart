import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remaking_booking_app_trail2/features/auth/test/hanzbthalk_theme.dart';

/// ---------------------------------------------------------------------------
/// Shared UI components for the Sign-Up Screen
///
/// Folder:  lib/features/auth/signup/ui/widgets/
/// ---------------------------------------------------------------------------

// ============================================================================
//  1. Branded Logo / Header
// ============================================================================
class HanzbthalkBrandHeader extends StatelessWidget {
  const HanzbthalkBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Animated brand icon container
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                HanzbthalkTheme.wasabiGreenLight,
                HanzbthalkTheme.wasabiGreenDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: HanzbthalkTheme.wasabiShadow,
          ),
          child: const Icon(
            Icons.sports_soccer_rounded,
            color: HanzbthalkTheme.offWhite,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Hanzbthalk',
          style: HanzbthalkTheme.displayTitle.copyWith(
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  HanzbthalkTheme.wasabiGreenLight,
                  HanzbthalkTheme.offWhite,
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Book. Play. Experience.',
          style: HanzbthalkTheme.caption.copyWith(
            color: HanzbthalkTheme.egyptianEarthLight,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
//  2. Glass Input Field
// ============================================================================
class GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLength;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  const GlassInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.maxLength,
    this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: HanzbthalkTheme.glassDecoration(),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        maxLength: maxLength,
        onChanged: onChanged,
        style: HanzbthalkTheme.body,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: HanzbthalkTheme.body.copyWith(
            color: HanzbthalkTheme.muted,
          ),
          prefixIcon: prefix,
          suffixIcon: suffix,
          counterText: '',
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HanzbthalkTheme.radiusInput),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HanzbthalkTheme.radiusInput),
            borderSide: const BorderSide(
              color: HanzbthalkTheme.wasabiGreen,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(HanzbthalkTheme.radiusInput),
            borderSide: const BorderSide(
              color: HanzbthalkTheme.error,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  3. OTP Input Row (6 boxes)
// ============================================================================
class OtpInputRow extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final bool enabled;

  const OtpInputRow({
    super.key,
    required this.onCompleted,
    this.enabled = true,
  });

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) widget.onCompleted(otp);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 48,
          height: 56,
          child: Container(
            decoration: HanzbthalkTheme.glassDecoration(borderRadius: 12),
            child: TextFormField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: HanzbthalkTheme.headline.copyWith(
                color: HanzbthalkTheme.wasabiGreenLight,
              ),
              onChanged: (v) => _onChanged(i, v),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ============================================================================
//  4. Wasabi CTA Button
// ============================================================================
class WasabiButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const WasabiButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(HanzbthalkTheme.radiusButton),
        gradient: LinearGradient(
          colors: onTap != null
              ? [
                  HanzbthalkTheme.wasabiGreenLight,
                  HanzbthalkTheme.wasabiGreenDark,
                ]
              : [HanzbthalkTheme.muted, HanzbthalkTheme.muted],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: onTap != null ? HanzbthalkTheme.wasabiShadow : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(HanzbthalkTheme.radiusButton),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isLoading
                  ? const _WasabiLoader()
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: HanzbthalkTheme.offWhite, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: HanzbthalkTheme.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.5,
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

// ============================================================================
//  5. Custom Brand Loader (Wasabi spinner)
// ============================================================================
class _WasabiLoader extends StatefulWidget {
  const _WasabiLoader();

  @override
  State<_WasabiLoader> createState() => _WasabiLoaderState();
}

class _WasabiLoaderState extends State<_WasabiLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(28, 28),
        painter: _WasabiSpinnerPainter(_ctrl.value),
      ),
    );
  }
}

class _WasabiSpinnerPainter extends CustomPainter {
  final double progress;
  _WasabiSpinnerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = HanzbthalkTheme.offWhite.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + (2 * math.pi * progress),
      math.pi * 1.2,
      false,
      Paint()
        ..color = HanzbthalkTheme.offWhite
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Green dot leading edge
    final angle = -math.pi / 2 + (2 * math.pi * progress) + math.pi * 1.2;
    final dotX = center.dx + radius * math.cos(angle);
    final dotY = center.dy + radius * math.sin(angle);
    canvas.drawCircle(
      Offset(dotX, dotY),
      3,
      Paint()..color = HanzbthalkTheme.egyptianEarthLight,
    );
  }

  @override
  bool shouldRepaint(_WasabiSpinnerPainter old) => old.progress != progress;
}

// ============================================================================
//  6. Terms & Privacy Checkbox Row
// ============================================================================
class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: HanzbthalkTheme.wasabiGreen,
            checkColor: HanzbthalkTheme.offWhite,
            side: const BorderSide(
              color: HanzbthalkTheme.glassBorder,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: RichText(
              text: TextSpan(
                style: HanzbthalkTheme.caption.copyWith(fontSize: 13),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => _launchTerms(context),
                      child: Text(
                        'Terms & Privacy Policy',
                        style: HanzbthalkTheme.caption.copyWith(
                          fontSize: 13,
                          color: HanzbthalkTheme.wasabiGreenLight,
                          decoration: TextDecoration.underline,
                          decorationColor: HanzbthalkTheme.wasabiGreenLight,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' of Hanzbthalk.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _launchTerms(BuildContext context) {
    // Use url_launcher in production:
    // launchUrl(Uri.parse('https://booking-68265.web.app/'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening Terms & Privacy…'),
        backgroundColor: HanzbthalkTheme.deepNoirCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ============================================================================
//  7. Error Banner
// ============================================================================
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HanzbthalkTheme.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: HanzbthalkTheme.error.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: HanzbthalkTheme.error,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: HanzbthalkTheme.caption.copyWith(
                color: HanzbthalkTheme.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
//  8. Section Divider with label
// ============================================================================
class LabeledDivider extends StatelessWidget {
  final String label;
  const LabeledDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: HanzbthalkTheme.glassBorder, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: HanzbthalkTheme.caption.copyWith(fontSize: 12),
          ),
        ),
        const Expanded(
          child: Divider(color: HanzbthalkTheme.glassBorder, thickness: 1),
        ),
      ],
    );
  }
}
