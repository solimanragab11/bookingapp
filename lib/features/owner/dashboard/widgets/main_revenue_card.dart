import 'package:flutter/material.dart';
import 'package:hanzbthalk/core/localization/app_localizations.dart';
import 'package:hanzbthalk/core/style_manger/color_manager.dart';

class MainRevenueCard extends StatelessWidget {
  final double totalRevenue;
  const MainRevenueCard({super.key, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorManager.wasabi.withOpacity(0.8), ColorManager.wasabi],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            context.tr('total_revenue_gross'),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$totalRevenue ${context.tr('egp')}",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
