import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceChart extends StatelessWidget {
  final List<List<double>> prices; 
  const PriceChart({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) return const Center(child: Text('No chart data'));

    final spots = prices.asMap().entries.map((e) {
      final idx = e.key.toDouble();
      final price = e.value[1];
      return FlSpot(idx, price);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return Card(
      color: const Color(0xFF071023),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LineChart(
          LineChartData(
            minY: minY * 0.995,
            maxY: maxY * 1.005,
            gridData: FlGridData(show: true, horizontalInterval: (maxY - minY) / 4),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                gradient: LinearGradient(colors: [Colors.cyanAccent, Colors.deepPurpleAccent]),
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.cyanAccent.withOpacity(0.2), Colors.transparent])),
              ),
            ],
            lineTouchData: LineTouchData(enabled: true, touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                return LineTooltipItem('\$${s.y.toStringAsFixed(2)}', const TextStyle(color: Colors.white));
              }).toList(),
            )),
          ),
        ),
      ),
    );
  }
}