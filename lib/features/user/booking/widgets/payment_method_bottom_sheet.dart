import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/localization_extension.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final double totalPrice;
  final double minimumDeposit;
  final double selectedPaymentAmount;
  final Function(PaymentMethod method) onSelected;

  const PaymentMethodBottomSheet({
    super.key,
    required this.totalPrice,
    required this.minimumDeposit,
    required this.selectedPaymentAmount,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('selectPaymentAmount'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: ColorManager.wasabi),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColorManager.wasabi.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorManager.wasabi, width: 1),
            ),
            child: Column(
              children: [
                Text(
                  context.tr('selectedAmount'),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedPaymentAmount.toStringAsFixed(0)} ${context.tr('egp')}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ColorManager.wasabi,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (selectedPaymentAmount < totalPrice)
                  Text(
                    '${context.tr('remainingAmount')}: ${(totalPrice - selectedPaymentAmount).toStringAsFixed(0)} ${context.tr('egp')}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ColorManager.egyptianEarth,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Pay via Wallet (Digital Payment Only)
          _buildPaymentOption(
            context: context,
            icon: Icons.wallet,
            title: context.tr('payViaWallet'),
            subtitle: context.tr('secureDigitalPayment'),
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              onSelected(PaymentMethod.walletPayment);
            },
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('allPaymentsMustBeDigital'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 28),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }
}

enum PaymentMethod { walletPayment }
