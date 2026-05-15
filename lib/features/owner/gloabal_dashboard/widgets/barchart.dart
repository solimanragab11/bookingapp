import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:remaking_booking_app_trail2/core/db/booking_analytics_service.dart';
import 'package:remaking_booking_app_trail2/core/style_manger/color_manager.dart';

class BarchartCust extends StatelessWidget {
  const BarchartCust({super.key, required this.places});
  final List<PlaceReport> places;
  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox();

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
      decoration: BoxDecoration(
        color: ColorManager.cardSurface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (places.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) *
              1.2),
          barGroups: places.asMap().entries.map((entry) {
            return _makeGroupData(
              entry.key,
              entry.value.revenue,
              entry.key % 2 == 0 ? ColorManager.wasabi : Colors.amber,
            );
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < places.length) {
                    return Text(
                      "P${index + 1}", // اختصار لـ Place
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 0,
            color: Colors.white10,
          ),
        ),
      ],
    );
  }
}
