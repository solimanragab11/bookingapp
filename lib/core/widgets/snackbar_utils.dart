import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class SnackBarUtils {
  /// Displays a premium styled success SnackBar
  static void showSuccess(BuildContext context, String msgKeyOrText) {
    final message = context.tr(msgKeyOrText, defaultValue: msgKeyOrText);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: ColorManager.emeraldGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ColorManager.cardSurface.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: ColorManager.emeraldGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Displays a premium styled error SnackBar
  static void showError(BuildContext context, String msgKeyOrText) {
    final message = context.tr(msgKeyOrText, defaultValue: msgKeyOrText);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ColorManager.cardSurface.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Displays a premium styled info SnackBar
  static void showInfo(BuildContext context, String msgKeyOrText) {
    final message = context.tr(msgKeyOrText, defaultValue: msgKeyOrText);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: ColorManager.wasabi,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ColorManager.cardSurface.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: ColorManager.wasabi,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Displays a premium styled loading SnackBar
  static void showLoading(BuildContext context, String msgKeyOrText) {
    final message = context.tr(msgKeyOrText, defaultValue: msgKeyOrText);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(ColorManager.wasabi),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: ColorManager.cardSurface.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1), // Keep open until manually dismissed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(
            color: ColorManager.wasabi,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Old method kept and styled for backward compatibility
  static void showErrorSnackBar(BuildContext context, String msg) {
    showError(context, "${context.tr('errorSaving')} $msg");
  }
}
