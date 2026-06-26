import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/features/user/dispute/cubit/dispute_cubit.dart';
import 'package:hanzbthalk/features/user/dispute/cubit/dispute_state.dart';
import 'package:hanzbthalk/features/user/user_bookings/cubit/user_bookings_cubit.dart';

class BookingDisputeSection extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDisputeSection({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final String bookingId = booking['id'] ?? '';
    final String placeId = booking['placeId'] ?? '';
    final String userId = booking['userId'] ?? '';

    // Translation keys and defaults
    final String title = context.tr(
      'pending_no_show_warning_title',
      defaultValue: 'تنبيه: تم تسجيلك كعدم حضور معلق!',
    );
    final String body = context.tr(
      'pending_no_show_warning_body',
      defaultValue: 'قام صاحب الملعب بوضعك كعدم حضور. إذا كنت متواجداً بالملعب، اضغط أدناه لتأكيد موقعك الجغرافي وإلغاء هذا الإجراء.',
    );
    final String buttonLabel = context.tr(
      'dispute_button_label',
      defaultValue: 'أنا في الملعب! (Dispute)',
    );
    final String checkingGpsText = context.tr(
      'checking_gps_progress',
      defaultValue: 'جاري التحقق من موقعك الفعلي بالـ GPS...',
    );

    return BlocProvider<DisputeCubit>(
      create: (_) => getIt<DisputeCubit>(),
      child: BlocConsumer<DisputeCubit, DisputeState>(
        listener: (context, state) {
          if (state is DisputeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr(
                    state.messageKey,
                    defaultValue: 'تم تحديث الحجز بنجاح!',
                  ),
                ),
                backgroundColor: ColorManager.emeraldGreen,
              ),
            );
            // Refresh parent user bookings list
            if (userId.isNotEmpty) {
              context.read<UserBookingsCubit>().fetchMyBookings(userId);
            }
          } else if (state is DisputeTooFar) {
            _showAdmitDialog(context, state);
          } else if (state is DisputeFailure) {
            String errorMsg = state.errorMessage;
            if (state.errorMessage == 'gps_disabled_error') {
              errorMsg = context.tr('gps_disabled_error', defaultValue: 'برجاء تشغيل تحديد الموقع (GPS) بالهاتف.');
            } else if (state.errorMessage == 'gps_permission_denied') {
              errorMsg = context.tr('gps_permission_denied', defaultValue: 'تم رفض صلاحية استخدام الموقع.');
            } else if (state.errorMessage == 'gps_permission_denied_forever') {
              errorMsg = context.tr('gps_permission_denied_forever', defaultValue: 'صلاحيات الموقع معطلة تماماً. يرجى تفعيلها من إعدادات الهاتف.');
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
          if (state is DisputeLoading) {
            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.orangeAccent,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      checkingGpsText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.redAccent.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.read<DisputeCubit>().disputeNoShow(
                        bookingId: bookingId,
                        placeId: placeId,
                      );
                    },
                    icon: const Icon(Icons.gps_fixed_rounded, size: 18),
                    label: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAdmitDialog(BuildContext context, DisputeTooFar state) {
    final String title = context.tr(
      'dispute_too_far_title',
      defaultValue: 'تنبيه: أنت بعيد عن الملعب!',
    );
    final String pointsText = context.tr(
      'current_points_label',
      defaultValue: 'نقاطك الحالية: {points}',
    ).replaceAll('{points}', state.currentPoints.toString());
    
    String consequences = '';
    if (state.noShowCount == 0) {
      consequences = context.tr(
        'first_no_show_consequence',
        defaultValue: 'لقد تبين أنك لست متواجداً بالملعب لتفنيد ادعاء صاحب الملعب. في حال إقرارك بعدم الحضور، سيتم خصم 20 نقطة من رصيدك كعقوبة (هذه أول مرة عدم حضور).',
      );
    } else {
      consequences = context.tr(
        'multi_no_show_consequence',
        defaultValue: 'لقد تبين أنك لست متواجداً بالملعب لتفنيد ادعاء صاحب الملعب. هذه هي المرة رقم {count} لعدم الحضور. سيتم خصم 20 نقطة وسيتم فرض قيود دفع عربون كامل مسبق على حجوزاتك الـ 3 القادمة.',
      ).replaceAll('{count}', (state.noShowCount + 1).toString());
    }

    final String confirmAdmit = context.tr(
      'admit_no_show_btn',
      defaultValue: 'إقرار بعدم الحضور (Admit)',
    );
    final String closeText = context.tr('closeBtn', defaultValue: 'إغلاق');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return BlocProvider<DisputeCubit>.value(
          value: BlocProvider.of<DisputeCubit>(context),
          child: BlocConsumer<DisputeCubit, DisputeState>(
            listener: (context, dialogState) {
              if (dialogState is DisputeSuccess) {
                Navigator.of(dialogCtx).pop(); // Close dialog on success
              }
            },
            builder: (context, dialogState) {
              final bool isLoading = dialogState is DisputeLoading;

              return AlertDialog(
                backgroundColor: ColorManager.cardSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.location_off_rounded, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pointsText,
                      style: const TextStyle(
                        color: ColorManager.creasedKhaki,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      consequences,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.of(dialogCtx).pop(),
                    child: Text(
                      closeText,
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            BlocProvider.of<DisputeCubit>(context).admitNoShow(
                              bookingId: state.bookingId,
                              userId: state.userId,
                            );
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
                            confirmAdmit,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
