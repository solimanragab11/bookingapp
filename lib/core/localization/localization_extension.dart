import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';

extension TranslateExtension on BuildContext {
  /// ترقية للـ BuildContext بتخليك تترجم أي كلمة بـ context.tr
  String tr(String key, {String defaultValue = ""}) {
    return AppLocalizations.of(this)?.translate(key) ??
        (defaultValue.isEmpty ? key : defaultValue);
  }
}
