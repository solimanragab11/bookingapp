import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';
import 'package:remaking_booking_app_trail2/core/localization/app_localizations.dart';

class RevenueComparisonChart extends StatelessWidget {
  final double appRevenue;
  final double manualRevenue;

  const RevenueComparisonChart({
    super.key,
    required this.appRevenue,
    required this.manualRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final double total = appRevenue + manualRevenue;
    final bool hasData = total > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.emeraldGreen, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr('revenue_split'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: ColorManager.creasedKhaki,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: !hasData
                ? const Center(
                    child: Icon(
                      Icons.pie_chart_outline,
                      color: ColorManager.wasabi,
                      size: 30,
                    ),
                  )
                : PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 15,
                      sections: [
                        PieChartSectionData(
                          value: appRevenue,
                          title:
                              "${((appRevenue / total) * 100).toStringAsFixed(0)}%",
                          color: ColorManager.egyptianEarth,
                          radius: 20,
                          titleStyle: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          value: manualRevenue,
                          title:
                              "${((manualRevenue / total) * 100).toStringAsFixed(0)}%",
                          color: ColorManager.wasabi,
                          radius: 20,
                          titleStyle: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("App", ColorManager.egyptianEarth),
              const SizedBox(width: 10),
              _buildLegendItem("Man.", ColorManager.wasabi),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: ColorManager.creasedKhaki),
        ),
      ],
    );
  }
}
