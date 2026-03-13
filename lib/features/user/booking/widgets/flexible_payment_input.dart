import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/localization/localization_extension.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class FlexiblePaymentInput extends StatefulWidget {
  final double totalPrice;
  final double minRequiredDeposit;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback? onPayNow;

  const FlexiblePaymentInput({
    super.key,
    required this.totalPrice,
    required this.minRequiredDeposit,
    required this.onAmountChanged,
    this.onPayNow,
  });

  @override
  State<FlexiblePaymentInput> createState() => _FlexiblePaymentInputState();
}

class _FlexiblePaymentInputState extends State<FlexiblePaymentInput> {
  late TextEditingController _amountController;
  double _selectedAmount = 0;
  bool _isValidAmount = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.minRequiredDeposit.toStringAsFixed(0),
    );
    _selectedAmount = widget.minRequiredDeposit;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toStringAsFixed(0);
      _validateAmount(amount);
    });
    widget.onAmountChanged(amount);
  }

  void _validateAmount(double amount) {
    setState(() {
      if (amount < widget.minRequiredDeposit) {
        _isValidAmount = false;
        _errorMessage =
            '${context.tr('amountMustBeGreater')} ${widget.minRequiredDeposit.toStringAsFixed(0)} ${context.tr('egp')}';
      } else if (amount > widget.totalPrice) {
        _isValidAmount = false;
        _errorMessage = context.tr('invalidAmount');
      } else {
        _isValidAmount = true;
        _errorMessage = '';
      }
    });
  }

  void _onManualInput(String value) {
    if (value.isEmpty) {
      setState(() {
        _isValidAmount = true;
        _errorMessage = '';
      });
      return;
    }

    final amount = double.tryParse(value);
    if (amount != null) {
      _selectedAmount = amount;
      _validateAmount(amount);
      widget.onAmountChanged(amount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingAmount = widget.totalPrice - _selectedAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isValidAmount ? ColorManager.wasabi : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            context.tr('selectPaymentAmount'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorManager.wasabi,
            ),
          ),
          const SizedBox(height: 12),

          // Quick Action Buttons
          Text(
            context.tr('quickActions'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuickActionButton(
                label: context.tr('minDeposit'),
                amount: widget.minRequiredDeposit,
                isSelected:
                    (_selectedAmount - widget.minRequiredDeposit).abs() < 0.01,
                onTap: () => _updateAmount(widget.minRequiredDeposit),
              ),
              const SizedBox(width: 10),
              _QuickActionButton(
                label: context.tr('halfPrice'),
                amount: widget.totalPrice / 2,
                isSelected:
                    (_selectedAmount - (widget.totalPrice / 2)).abs() < 0.01,
                onTap: () => _updateAmount(widget.totalPrice / 2),
              ),
              const SizedBox(width: 10),
              _QuickActionButton(
                label: context.tr('fullPrice'),
                amount: widget.totalPrice,
                isSelected: (_selectedAmount - widget.totalPrice).abs() < 0.01,
                onTap: () => _updateAmount(widget.totalPrice),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Custom Amount Input
          Text(
            context.tr('customAmount'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: _onManualInput,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorManager.wasabi,
            ),
            decoration: InputDecoration(
              hintText: context.tr('enterAmount'),
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffix: Text(
                context.tr('egp'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: ColorManager.wasabi,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: ColorManager.wasabi,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: ColorManager.wasabi,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Error Message
          if (!_isValidAmount)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: ColorManager.egyptianEarth,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorManager.egyptianEarth,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Payment Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('paymentAmount'),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedAmount.toStringAsFixed(0)} ${context.tr('egp')}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.wasabi,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.tr('remainingAmount'),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${remainingAmount.toStringAsFixed(0)} ${context.tr('egp')}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: remainingAmount > 0
                          ? ColorManager.egyptianEarth
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? ColorManager.wasabi : Colors.white,
            border: Border.all(
              color: ColorManager.wasabi,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : ColorManager.wasabi,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${amount.toStringAsFixed(0)} ${context.tr('egp')}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : ColorManager.wasabi,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
