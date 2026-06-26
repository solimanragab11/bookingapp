import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/models/booking_model.dart';
import 'package:hanzbthalk/core/models/user_model.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';
import 'package:hanzbthalk/core/db/booking_service.dart';
import 'package:hanzbthalk/core/db/auth_service.dart';
import 'package:hanzbthalk/core/di/dependency_injection.dart';
import 'package:hanzbthalk/features/owner/place_schedule/widgets/employee_no_show_button.dart';
import 'package:hanzbthalk/features/owner/place_schedule/widgets/cash_collection_dialog.dart';

class BookingDetailsBottomSheet extends StatefulWidget {
  final String bookingId;
  final String bookerName;
  final String bookedBy; // 'user' or 'owner'
  final String slotTime;
  final String rawSlotTime; // Raw 24h format like "10:00"
  final bool canCancel;
  final VoidCallback onSelectForCancellation;

  const BookingDetailsBottomSheet({
    super.key,
    required this.bookingId,
    required this.bookerName,
    required this.bookedBy,
    required this.slotTime,
    required this.rawSlotTime,
    required this.canCancel,
    required this.onSelectForCancellation,
  });

  static void show({
    required BuildContext context,
    required String bookingId,
    required String bookerName,
    required String bookedBy,
    required String slotTime,
    required String rawSlotTime,
    required bool canCancel,
    required VoidCallback onSelectForCancellation,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BookingDetailsBottomSheet(
        bookingId: bookingId,
        bookerName: bookerName,
        bookedBy: bookedBy,
        slotTime: slotTime,
        rawSlotTime: rawSlotTime,
        canCancel: canCancel,
        onSelectForCancellation: onSelectForCancellation,
      ),
    );
  }

  @override
  State<BookingDetailsBottomSheet> createState() =>
      _BookingDetailsBottomSheetState();
}

class _BookingDetailsBottomSheetState extends State<BookingDetailsBottomSheet> {
  late Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _fetchDetails();
  }



  Future<Map<String, dynamic>> _fetchDetails() async {
    try {
      final bookingService = getIt<BookingService>();
      final authService = getIt<AuthService>();

      debugPrint("[BookingDetailsBottomSheet] Fetching booking by ID: ${widget.bookingId}");
      final BookingModel? booking = await bookingService.getBookingById(
        widget.bookingId,
      );
      
      debugPrint("[BookingDetailsBottomSheet] Booking fetched: $booking");
      UserModel? user;

      if (booking != null) {
        debugPrint("[BookingDetailsBottomSheet] Fetching user by ID: ${booking.userId}");
        user = await authService.getUserById(booking.userId);
        debugPrint("[BookingDetailsBottomSheet] User fetched: $user");
      }

      return {'booking': booking, 'user': user};
    } catch (e, stackTrace) {
      debugPrint("❌ [BookingDetailsBottomSheet] Error in _fetchDetails: $e");
      debugPrint("$stackTrace");
      rethrow;
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (_) {}
  }

  Future<void> _sendWhatsApp(String phone, String bookerName) async {
    var cleanPhone = phone.trim();
    if (!cleanPhone.startsWith('+') && !cleanPhone.startsWith('00')) {
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '+2$cleanPhone'; // default to Egypt format
      } else if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+$cleanPhone';
      }
    }

    // Check clean phone contains digits
    cleanPhone = cleanPhone.replaceAll(RegExp(r'\s+|-'), '');

    final String locale = Localizations.localeOf(context).languageCode;
    final message = locale == 'ar'
        ? "مرحباً $bookerName، أتواصل معك بخصوص حجز الملعب الخاص بك."
        : "Hello $bookerName, contacting you regarding your field booking.";

    final Uri whatsappUri = Uri.parse(
      "https://wa.me/${cleanPhone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}",
    );
    try {
      if (await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
        // Chat opened
      }
    } catch (_) {}
  }



  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: ColorManager.cardSurface.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: ColorManager.emeraldGreen.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _detailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 250,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ColorManager.wasabi,
                    ),
                  ),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data?['booking'] == null) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      context.tr(
                        'booking_details_error',
                        defaultValue: 'Could not fetch booking details.',
                      ),
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }

              final BookingModel booking =
                  snapshot.data!['booking'] as BookingModel;
              final UserModel? user = snapshot.data!['user'] as UserModel?;

              // Determine contact number
              String contactPhone = '';
              String displayBookerName = widget.bookerName;

              if (user != null) {
                contactPhone = user.phoneNumber;
                displayBookerName = user.username;
              } else {
                // If user is null, it means we don't have a registered user document.
                // For manual bookings without a registered account, the phone number is stored in the userId field.
                if (booking.userId != 'unknown_user' &&
                    booking.userId.length > 5) {
                  contactPhone = booking.userId;
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull indicator
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.tr(
                      'booking_details_title',
                      defaultValue: 'Booking Details',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 25),

                  // Detail Rows
                  _buildDetailRow(
                    context,
                    Icons.person_outline_rounded,
                    context.tr('booker_name', defaultValue: 'Booker Name'),
                    displayBookerName,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.access_time_rounded,
                    context.tr('booking_time', defaultValue: 'Time Slot'),
                    widget.slotTime,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.payments_outlined,
                    context.tr(
                      'payment_method',
                      defaultValue: 'Payment Method',
                    ),
                    booking.isCash
                        ? context.tr('payment_cash', defaultValue: 'Cash')
                        : context.tr(
                            'payment_wallet',
                            defaultValue: 'Wallet / Online',
                          ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.monetization_on_outlined,
                    context.tr('total_price', defaultValue: 'Total Price'),
                    '${booking.totalPrice.toStringAsFixed(0)} ${context.tr('currency', defaultValue: 'EGP')}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.savings_outlined,
                    context.tr(
                      'paid_amount',
                      defaultValue: 'Amount Paid (Deposit)',
                    ),
                    '${booking.paidAmount.toStringAsFixed(0)} ${context.tr('currency', defaultValue: 'EGP')}',
                  ),

                  if (contactPhone.isNotEmpty) ...[
                    const Divider(color: Colors.white12, height: 30),
                    Text(
                      context.tr(
                        'contact_customer',
                        defaultValue: 'Contact Booker',
                      ),
                      style: const TextStyle(
                        color: ColorManager.creasedKhaki,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // WhatsApp Button
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.greenAccent,
                              side: BorderSide(
                                color: Colors.greenAccent.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _sendWhatsApp(contactPhone, displayBookerName);
                            },
                            icon: const Icon(Icons.message_rounded, size: 20),
                            label: Text(
                              context.tr('whatsapp', defaultValue: 'WhatsApp'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Call Button
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.egyptianEarth,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _makeCall(contactPhone);
                            },
                            icon: const Icon(
                              Icons.phone_in_talk_rounded,
                              size: 20,
                            ),
                            label: Text(
                              context.tr('call', defaultValue: 'Call'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (booking.isCash && !booking.isCashSettled) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.creasedKhaki,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final bool? success = await showDialog<bool>(
                            context: context,
                            builder: (dialogCtx) => CashCollectionDialog(
                              bookingId: booking.id,
                            ),
                          );
                          if (success == true && context.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                          }
                        },
                        icon: const Icon(Icons.monetization_on_rounded),
                        label: Text(
                          context.tr(
                            'confirm_cash_received_btn',
                            defaultValue: 'Confirm Cash Received',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],

                  if (booking.bookedBy == 'user') ...[
                    if (booking.status == 'attended') ...[
                      if (!booking.isCash && booking.totalPrice > booking.paidAmount) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.tr(
                                    'owner_pay_rest_pin_required',
                                    defaultValue: 'Please ask the user to click "Pay Rest" on their app to generate a cash verification PIN.',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else if (booking.status == 'active' || booking.status.isEmpty) ...[
                      const SizedBox(height: 16),
                      EmployeeNoShowButton(booking: booking.toJson()),
                    ],
                  ],

                  if (widget.canCancel) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.redAccent.withOpacity(0.3),
                            ),
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          widget.onSelectForCancellation();
                        },
                        icon: const Icon(Icons.delete_sweep_rounded),
                        label: Text(
                          context.tr(
                            'select_for_cancellation',
                            defaultValue: 'Select for Cancellation',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: ColorManager.creasedKhaki, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
