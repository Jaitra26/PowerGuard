import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/energy_reading.dart';
import '../theme/app_theme.dart';

class EnergyChart extends StatelessWidget {
  final List<EnergyReading> readings;
  final bool showPredictionLine;

  const EnergyChart({
    super.key,
    required this.readings,
    this.showPredictionLine = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text("No chart data available"),
      );
    }

    final theme = Theme.of(context);

    // Compute min/max for scaling
    double minX = 0;
    double maxX = (readings.length - 1).toDouble();

    double minY = readings.map((r) => r.actualLoad).reduce((a, b) => a < b ? a : b);
    double maxY = readings.map((r) => r.actualLoad).reduce((a, b) => a > b ? a : b);
    
    if (showPredictionLine) {
      double minPred = readings.map((r) => r.predictedLoad).reduce((a, b) => a < b ? a : b);
      double maxPred = readings.map((r) => r.predictedLoad).reduce((a, b) => a > b ? a : b);
      minY = minY < minPred ? minY : minPred;
      maxY = maxY > maxPred ? maxY : maxPred;
    }

    // Add padding to Y range
    minY = (minY - 10).clamp(0.0, double.infinity);
    maxY = maxY + 15;

    // Convert readings to spots
    final List<FlSpot> actualSpots = [];
    final List<FlSpot> predictedSpots = [];

    for (int i = 0; i < readings.length; i++) {
      actualSpots.add(FlSpot(i.toDouble(), readings[i].actualLoad));
      if (showPredictionLine) {
        predictedSpots.add(FlSpot(i.toDouble(), readings[i].predictedLoad));
      }
    }

    const predictionColor = Color(0xFF89CFF0); // Light Blue

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: (maxY - minY) / 4,
            verticalInterval: maxX / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.outlineVariant.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: AppTheme.outlineVariant.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY - minY) / 3,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${value.toInt()}M',
                      style: AppTheme.geistMonoStyle(
                        fontSize: 10,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (readings.length / 4).roundToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < readings.length) {
                    final timestamp = readings[index].timestamp;
                    final timeLabel = DateFormat('HH:mm').format(timestamp);
                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        timeLabel,
                        style: AppTheme.geistMonoStyle(
                          fontSize: 10,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 24,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppTheme.surfaceContainerHighest,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final reading = readings[spot.x.toInt()];
                  final isActual = spot.barIndex == 0;
                  final prefix = isActual ? "Actual: " : "Forecast: ";
                  return LineTooltipItem(
                    '$prefix${spot.y.toStringAsFixed(1)} MW\n',
                    theme.textTheme.bodySmall?.copyWith(
                      color: isActual ? AppTheme.primary : predictionColor,
                      fontWeight: FontWeight.bold,
                    ) ?? const TextStyle(),
                    children: [
                      TextSpan(
                        text: DateFormat('HH:mm').format(reading.timestamp),
                        style: AppTheme.geistMonoStyle(
                          fontSize: 10,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Actual load line
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            // Predicted load line
            if (showPredictionLine)
              LineChartBarData(
                spots: predictedSpots,
                isCurved: true,
                color: predictionColor,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      predictionColor.withValues(alpha: 0.1),
                      predictionColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
