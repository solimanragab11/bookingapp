import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_cubit.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_state.dart';

class CashCollectionDialog extends StatefulWidget {
  final String bookingId;

  const CashCollectionDialog({
    super.key,
    required this.bookingId,
  });

  @override
  State<CashCollectionDialog> createState() => _CashCollectionDialogState();
}

class _CashCollectionDialogState extends State<CashCollectionDialog> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Translation strings
    final String title = context.tr(
      'cash_collection_title',
      defaultValue: 'تأكيد استلام النقدية',
    );
    final String infoText = context.tr(
      'cash_collection_info',
      defaultValue: 'يرجى إدخال الرمز المكون من 4 أرقام المعروض لدى العميل لتأكيد استلام المبلغ.',
    );
    final String pinLabel = context.tr(
      'enter_pin_label',
      defaultValue: 'أدخل الرمز (PIN)',
    );
    final String cancelText = context.tr('cancelBtn', defaultValue: 'إلغاء');
    final String confirmText = context.tr('confirm', defaultValue: 'تأكيد');
    final String pinRequired = context.tr(
      'pin_required_error',
      defaultValue: 'الرمز مطلوب',
    );
    final String pinLengthError = context.tr(
      'pin_length_error',
      defaultValue: 'يجب أن يتكون الرمز من 4 أرقام',
    );

    return BlocProvider<EmployeeBookingCubit>(
      create: (_) => getIt<EmployeeBookingCubit>(),
      child: BlocConsumer<EmployeeBookingCubit, EmployeeBookingState>(
        listener: (context, state) {
          if (state is EmployeeBookingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr(
                    state.messageKey,
                    defaultValue: 'تم تأكيد استلام النقدية بنجاح!',
                  ),
                ),
                backgroundColor: ColorManager.emeraldGreen,
              ),
            );
            Navigator.of(context).pop(true); // Close dialog with true
          } else if (state is EmployeeBookingFailure) {
            String errorMsg = state.errorMessage;
            if (state.errorMessage == 'invalid_cash_pin') {
              errorMsg = context.tr('invalid_cash_pin', defaultValue: 'الرمز المدخل غير صحيح. يرجى المحاولة مجدداً.');
            } else {
              errorMsg = context.tr(state.errorMessage, defaultValue: state.errorMessage);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is EmployeeBookingLoading;

          return AlertDialog(
            backgroundColor: ColorManager.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: ColorManager.creasedKhaki, width: 1.5),
            ),
            title: Row(
              children: [
                const Icon(Icons.monetization_on_outlined, color: ColorManager.creasedKhaki),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    infoText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: '0000',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.2),
                        letterSpacing: 8,
                      ),
                      labelText: pinLabel,
                      labelStyle: const TextStyle(
                        color: ColorManager.creasedKhaki,
                        fontSize: 12,
                        letterSpacing: 0,
                      ),
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: ColorManager.creasedKhaki,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return pinRequired;
                      }
                      if (value.trim().length != 4) {
                        return pinLengthError;
                      }
                      return null;
                    },
                    enabled: !isLoading,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(false),
                child: Text(
                  cancelText,
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.creasedKhaki,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          HapticFeedback.mediumImpact();
                          context.read<EmployeeBookingCubit>().confirmCashCollection(
                                bookingId: widget.bookingId,
                                enteredPin: _pinController.text.trim(),
                              );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
