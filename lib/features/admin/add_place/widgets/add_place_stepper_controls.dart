import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class AddPlaceStepperControls extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback? onCancel;
  final bool isLastStep;

  const AddPlaceStepperControls(
    ControlsDetails details, {
    super.key,
    required this.onContinue,
    this.onCancel,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.wasabi,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: onContinue,
              child: Text(
                isLastStep ? context.tr('Save') : context.tr('Confirm'),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (onCancel != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ColorManager.egyptianEarth),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: onCancel,
                child: Text(
                  context.tr('Cancel'),
                  style: TextStyle(color: ColorManager.egyptianEarth),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
