import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// HanzbthalkTheme — Brand design tokens
///
/// Folder:  lib/core/theme/
/// ---------------------------------------------------------------------------
abstract class HanzbthalkTheme {
  // ── Palette ──────────────────────────────────────────
  /// Primary — Wasabi Green
  static const Color wasabiGreen = Color(0xFF7A9A3F);
  static const Color wasabiGreenLight = Color(0xFF9BBF52);
  static const Color wasabiGreenDark = Color(0xFF5A7A2A);

  /// Background — Deep Noir (Dark mode)
  static const Color deepNoir = Color(0xFF0D0D0D);
  static const Color deepNoirSurface = Color(0xFF161616);
  static const Color deepNoirCard = Color(0xFF1E1E1E);

  /// Accent — Egyptian Earth
  static const Color egyptianEarth = Color(0xFFC8773A);
  static const Color egyptianEarthLight = Color(0xFFE89A5A);

  /// Neutrals
  static const Color offWhite = Color(0xFFF0EDE8);
  static const Color muted = Color(0xFF8A8A8A);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  /// Error
  static const Color error = Color(0xFFE05252);

  // ── Typography ───────────────────────────────────────
  static const String arefRuqaa = 'ArefRuqaa';
  static const String defaultFont = 'Cairo'; // fallback body

  static const TextStyle displayTitle = TextStyle(
    fontFamily: arefRuqaa,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: offWhite,
    letterSpacing: 0.5,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: arefRuqaa,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: offWhite,
  );

  static const TextStyle body = TextStyle(
    fontFamily: defaultFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: offWhite,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: defaultFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: muted,
  );

  // ── Radii & Spacing ──────────────────────────────────
  static const double radiusInput = 16.0;
  static const double radiusButton = 14.0;
  static const double radiusCard = 20.0;

  // ── Glassmorphism decoration ─────────────────────────
  static BoxDecoration glassDecoration({
    double borderRadius = radiusInput,
    Color? borderColor,
  }) =>
      BoxDecoration(
        color: glassWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? glassBorder,
          width: 1.2,
        ),
      );

  // ── Button shadow ─────────────────────────────────────
  static List<BoxShadow> get wasabiShadow => [
        BoxShadow(
          color: wasabiGreen.withOpacity(0.45),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];
}
