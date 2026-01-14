import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyProgressBar extends StatelessWidget {
  const WeeklyProgressBar({super.key, required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          barGroups: List.generate(values.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i].toDouble(),
                  width: 10,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          maxY: 1,
          minY: 0,
        ),
      ),
    );
  }
}
