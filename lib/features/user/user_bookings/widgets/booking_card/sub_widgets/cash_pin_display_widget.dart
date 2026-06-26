import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class CashPinDisplayWidget extends StatefulWidget {
  final String cashPin;

  const CashPinDisplayWidget({
    super.key,
    required this.cashPin,
  });

  @override
  State<CashPinDisplayWidget> createState() => _CashPinDisplayWidgetState();
}

class _CashPinDisplayWidgetState extends State<CashPinDisplayWidget> {
  bool _obscurePin = true;

  @override
  Widget build(BuildContext context) {
    final String warningText = context.tr(
      'cash_pin_warning_text',
      defaultValue: 'تنبيه: لا تقم بإعطاء هذا الرمز للموظف حتى تسلمه المبلغ النقدي.',
    );
    final String pinLabel = context.tr(
      'cash_pin_label',
      defaultValue: 'رمز تأكيد الدفع النقدي (PIN)',
    );

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorManager.creasedKhaki.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.vpn_key_rounded,
                color: ColorManager.creasedKhaki,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pinLabel,
                  style: const TextStyle(
                    color: ColorManager.creasedKhaki,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(widget.cashPin.length, (index) {
                  final String char = _obscurePin ? '•' : widget.cashPin[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 32,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      char,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                }),
              ),
              IconButton(
                icon: Icon(
                  _obscurePin ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _obscurePin = !_obscurePin;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Colors.orangeAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  warningText,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
