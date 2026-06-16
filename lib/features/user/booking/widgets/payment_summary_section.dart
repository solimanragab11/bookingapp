import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class PaymentSummarySection extends StatelessWidget {
  final double totalPrice;
  final double requiredDeposit;

  const PaymentSummarySection({
    super.key,
    required this.totalPrice,
    required this.requiredDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            context,
            context.tr('totalAmountColon'),
            '${totalPrice.toStringAsFixed(2)} ${context.tr('le')}',
            Colors.white,
            16,
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            context,
            context.tr('minimumDepositColon'),
            '${requiredDeposit.toStringAsFixed(2)} ${context.tr('le')}',
            ColorManager.creasedKhaki,
            14,
            isDeposit: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
    double fontSize, {
    bool isDeposit = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white60,
            fontSize: fontSize,
            fontWeight: isDeposit ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
