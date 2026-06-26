import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_cubit.dart';
import 'package:hanzbthalk/features/owner/logic/employee_booking_cubit/employee_booking_state.dart';
import 'package:hanzbthalk/features/user/user_bookings/widgets/booking_card/sub_widgets/booking_time_helper.dart';

class EmployeeNoShowButton extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onSuccess;

  const EmployeeNoShowButton({
    super.key,
    required this.booking,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final bool allowed = BookingTimeHelper.isNoShowActionAllowed(booking);
    final String bookingId = booking['id'] ?? '';

    // Localization strings
    final String labelText = context.tr(
      'mark_no_show',
      defaultValue: 'Mark No Show',
    );
    final String lockedTooltip = context.tr(
      'no_show_locked_tooltip',
      defaultValue: 'Locked until 50% of the match duration passes.',
    );
    final String confirmTitle = context.tr(
      'confirm_no_show_title',
      defaultValue: 'Confirm No Show',
    );
    final String confirmMsg = context.tr(
      'confirm_no_show_msg',
      defaultValue: 'Are you sure you want to mark this booking as No Show? This will update the booking status to pending no-show.',
    );
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
                    defaultValue: 'Booking status updated to pending no-show.',
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
                  color: Colors.orangeAccent,
                ),
              ),
            );
          }

          if (!allowed) {
            // Disabled Grayed out state
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: null, // Disabled
                    icon: const Icon(Icons.lock_outline_rounded, color: Colors.grey),
                    label: Text(
                      labelText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lockedTooltip,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          // Active clickable state
          return SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.orangeAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.orangeAccent.withOpacity(0.4),
                  ),
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
                      side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
                    ),
                    title: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
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
                          backgroundColor: Colors.orangeAccent,
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
                  context.read<EmployeeBookingCubit>().markPendingNoShow(
                    bookingId: bookingId,
                  );
                }
              },
              icon: const Icon(Icons.person_off_rounded),
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
