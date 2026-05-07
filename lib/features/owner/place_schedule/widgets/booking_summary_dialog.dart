import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';
import 'package:remaking_booking_app_trail2/core/models/place.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

enum DialogMood { booking, cancellation }

class BookingSummaryDialog extends StatefulWidget {
  final PlaceModel place;
  final List<String> selectedSlots;
  final double totalPrice;
  final DialogMood mood;
  final Function({required String phone, required double deposit}) onConfirmed;

  const BookingSummaryDialog({
    super.key,
    required this.place,
    required this.selectedSlots,
    required this.totalPrice,
    required this.mood,
    required this.onConfirmed,
  });

  static void show({
    required BuildContext context,
    required PlaceModel place,
    required List<String> selectedSlots,
    required double totalPrice,
    required DialogMood mood,
    required Function({required String phone, required double deposit})
    onConfirmed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingSummaryDialog(
        place: place,
        selectedSlots: selectedSlots,
        totalPrice: totalPrice,
        mood: mood,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<BookingSummaryDialog> createState() => _BookingSummaryDialogState();
}

class _BookingSummaryDialogState extends State<BookingSummaryDialog> {
  final _phoneController = TextEditingController();
  final _depositController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // اقتراح مبلغ العربون (50% من الإجمالي) كمبدأ
    if (widget.mood == DialogMood.booking) {
      double suggestedDeposit = widget.totalPrice * 0.5;
      _depositController.text = suggestedDeposit.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBooking = widget.mood == DialogMood.booking;

    return AlertDialog(
      backgroundColor: ColorManager.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: _buildTitle(isBooking),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(isBooking),
              if (isBooking) ...[
                const Divider(color: Colors.white24, height: 30),
                _buildBookingFields(),
              ],
            ],
          ),
        ),
      ),
      actions: _buildActions(context, isBooking),
    );
  }

  Widget _buildTitle(bool isBooking) {
    return Row(
      children: [
        Icon(
          isBooking ? Icons.add_moderator : Icons.delete_forever,
          color: isBooking ? ColorManager.wasabi : Colors.redAccent,
        ),
        const SizedBox(width: 10),
        Text(
          isBooking ? context.tr('newBooking') : context.tr('confirmDeletion'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isBooking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(context.tr('placeColon'), widget.place.name),
        _infoRow(
          context.tr('selectedHours'),
          '${widget.selectedSlots.length} ${context.tr(widget.selectedSlots.length == 1 ? 'hour_singular' : 'hour_plural')}',
        ),
        if (isBooking) ...[
          _infoRow(
            context.tr('total'),
            '${widget.totalPrice} ${context.tr('le')}',
          ),
          const SizedBox(height: 8),
          Text(
            '${context.tr('minimumRequiredDeposit')}: ${(widget.totalPrice * 0.5).toStringAsFixed(0)} ${context.tr('le')}',
            style: TextStyle(
              color: ColorManager.wasabi.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
        if (!isBooking)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              context.tr('areYouSureDelete'),
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildBookingFields() {
    return Column(
      children: [
        _buildCustomTextField(
          label: context.tr('phoneNumber'),
          controller: _phoneController,
          hint: context.tr('elevenDigits'),
          keyboardType: TextInputType.phone,
          validator: (val) =>
              (val == null || val.isEmpty) ? context.tr('phoneRequired') : null,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          label: context.tr('paymentAmount'),
          controller: _depositController,
          hint: '0.0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (val) =>
              (val == null || val.isEmpty) ? context.tr('fieldRequired') : null,
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isBooking) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          context.tr('cancel'),
          style: const TextStyle(color: Colors.white54),
        ),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isBooking ? ColorManager.wasabi : Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if (isBooking && !_formKey.currentState!.validate()) return;

          Navigator.pop(context);
          widget.onConfirmed(
            phone: _phoneController.text.trim(),
            deposit: double.tryParse(_depositController.text) ?? 0.0,
          );
        },
        child: Text(
          isBooking ? context.tr('confirm') : context.tr('delete'),
          style: TextStyle(
            color: isBooking ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
