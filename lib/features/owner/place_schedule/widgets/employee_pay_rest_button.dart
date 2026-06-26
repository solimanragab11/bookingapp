import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_cubit.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_state.dart';

class EmployeePayRestButton extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onSuccess;

  const EmployeePayRestButton({
    super.key,
    required this.booking,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final String bookingId = booking['id'] ?? '';
    final double total = (booking['totalPrice'] ?? 0).toDouble();
    final double paid = (booking['paidAmount'] ?? 0).toDouble();
    final double remaining = total - paid;

    // Localization strings
    final String labelText = context.tr(
      'pay_rest_btn',
      defaultValue: 'Confirm Cash Received',
    );
    final String confirmTitle = context.tr(
      'confirm_pay_rest_title',
      defaultValue: 'Confirm Cash Payment',
    );
    final String confirmMsg = context.tr(
      'confirm_pay_rest_msg',
      defaultValue: 'Are you sure you want to confirm receipt of the remaining balance of {} EGP?',
    ).replaceAll('{}', remaining.toStringAsFixed(0));

    final String cancelText = context.tr('cancelBtn', defaultValue: 'Cancel');
    final String confirmText = context.tr('confirm', defaultValue: 'Confirm');

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
                    defaultValue: 'Remaining balance settled successfully!',
                  ),
                ),
                backgroundColor: ColorManager.emeraldGreen,
              ),
            );
            if (onSuccess != null) {
              onSuccess!();
            }
            Navigator.of(context).pop(); // Close bottom sheet
          } else if (state is EmployeeBookingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr(
                    state.errorMessage,
                    defaultValue: 'Error: ${state.errorMessage}',
                  ),
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EmployeeBookingLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: CircularProgressIndicator(
                  color: ColorManager.wasabi,
                ),
              ),
            );
          }

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.wasabi,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    backgroundColor: ColorManager.cardSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: ColorManager.wasabi, width: 1.5),
                    ),
                    title: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: ColorManager.wasabi),
                        const SizedBox(width: 10),
                        Text(
                          confirmTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      confirmMsg,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(false),
                        child: Text(
                          cancelText,
                          style: TextStyle(color: Colors.white.withOpacity(0.6)),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.wasabi,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogCtx).pop(true),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  context.read<EmployeeBookingCubit>().settleRemainingPayment(
                    bookingId: bookingId,
                    totalPrice: total,
                  );
                }
              },
              icon: const Icon(Icons.monetization_on_rounded),
              label: Text(
                labelText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}
