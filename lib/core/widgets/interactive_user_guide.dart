import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/style_manger/text_style_mangare.dart';

class InteractiveUserGuide extends StatefulWidget {
  final Map<String, GlobalKey> targetKeys;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  const InteractiveUserGuide({
    super.key,
    required this.targetKeys,
    required this.onFinish,
    required this.onSkip,
  });

  @override
  State<InteractiveUserGuide> createState() => _InteractiveUserGuideState();
}

class _InteractiveUserGuideState extends State<InteractiveUserGuide>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _steps = [
    'welcome',
    'logo',
    'menu',
    'bookings',
    'search',
    'filters',
    'categories',
    'tabs',
    'firstCard',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  GlobalKey? _getStepKey() {
    final step = _steps[_currentStep];
    if (step == 'welcome') return null;
    return widget.targetKeys[step];
  }

  String _getStepTitleKey() {
    final step = _steps[_currentStep];
    return 'guide_${step}_title';
  }

  String _getStepDescKey() {
    final step = _steps[_currentStep];
    return 'guide_${step}_desc';
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onFinish();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final stepKey = _getStepKey();
    Offset? targetOffset;
    Size? targetSize;

    if (stepKey != null) {
      final renderBox = stepKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        targetOffset = renderBox.localToGlobal(Offset.zero);
        targetSize = renderBox.size;
      }
    }

    final cardWidget = _buildInfoCard(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Custom spotlight painter overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: SpotlightPainter(
                    targetOffset: targetOffset,
                    targetSize: targetSize,
                    pulseValue: _pulseAnimation.value,
                  ),
                ),
              ),

              // Invisible overlay intercepting taps
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    // Tap outside card does nothing to keep guide focused
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

              // Description Card
              if (targetOffset == null || targetSize == null)
                Center(child: cardWidget)
              else
                () {
                  final offset = targetOffset!;
                  final size = targetSize!;
                  double targetCenterY = offset.dy + (size.height / 2);
                  bool showBelow = targetCenterY < screenHeight / 2;

                  return Positioned(
                    left: 20,
                    right: 20,
                    top: showBelow ? (offset.dy + size.height + 16) : null,
                    bottom: !showBelow ? (screenHeight - offset.dy + 16) : null,
                    child: cardWidget,
                  );
                }(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final isLast = _currentStep == _steps.length - 1;
    final isFirst = _currentStep == 0;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: ColorManager.cardSurface.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: ColorManager.emeraldGreen.withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorManager.emeraldGreen.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Step indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorManager.egyptianEarth.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ColorManager.egyptianEarth.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "${_currentStep + 1} / ${_steps.length}",
                          style: const TextStyle(
                            color: ColorManager.egyptianEarth,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (!isLast)
                        TextButton(
                          onPressed: widget.onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white60,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            context.tr('guide_skip'),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    context.tr(_getStepTitleKey()),
                    style: TextStyleMangare.headingStyle.copyWith(
                      color: ColorManager.creasedKhaki,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description text
                  Text(
                    context.tr(_getStepDescKey()),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isFirst)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _prevStep,
                          child: Text(
                            context.tr('guide_back'),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.egyptianEarth,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _nextStep,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast
                                  ? context.tr('guide_finish')
                                  : context.tr('guide_next'),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isLast ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
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

class SpotlightPainter extends CustomPainter {
  final Offset? targetOffset;
  final Size? targetSize;
  final double pulseValue;

  SpotlightPainter({
    required this.targetOffset,
    required this.targetSize,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (targetOffset == null || targetSize == null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black.withOpacity(0.75),
      );
      return;
    }

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // 1. Draw overlay background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withOpacity(0.75),
    );

    // 2. Cut out target spotlight shape (RRect)
    final Rect targetRect = Rect.fromLTWH(
      targetOffset!.dx - 8,
      targetOffset!.dy - 8,
      targetSize!.width + 16,
      targetSize!.height + 16,
    );

    final Paint clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..isAntiAlias = true;

    final RRect rrect = RRect.fromRectAndRadius(
      targetRect,
      const Radius.circular(16),
    );
    canvas.drawRRect(rrect, clearPaint);

    canvas.restore();

    // 3. Draw pulsing outer glow border
    final Paint glowPaint = Paint()
      ..color = ColorManager.egyptianEarth.withOpacity(0.8 - (pulseValue * 0.4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + (pulseValue * 4.0)
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3.0 + (pulseValue * 5.0));

    canvas.drawRRect(rrect, glowPaint);

    // 4. Draw sharp inner border
    final Paint borderPaint = Paint()
      ..color = ColorManager.egyptianEarth
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetOffset != targetOffset ||
        oldDelegate.targetSize != targetSize ||
        oldDelegate.pulseValue != pulseValue;
  }
}
