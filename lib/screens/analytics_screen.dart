import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../providers/energy_provider.dart';
import '../widgets/energy_chart.dart';
import '../widgets/status_badge.dart';
import '../widgets/scale_on_press.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final energy = context.read<EnergyProvider>();
      if (energy.readings.isEmpty) {
        energy.fetchReadings();
      }
    });
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.geistMonoStyle(
                    fontSize: 10,
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final energy = Provider.of<EnergyProvider>(context);

    // Dynamic metrics based on selected range
    String totalConsumption = "24,810 kWh";
    String peakDemand = "189.2 MW";
    String avgDaily = "3,544 kWh";
    String anomaliesDetected = "3";

    if (energy.activeAnalyticsPeriod == "30 Days") {
      totalConsumption = "106,430 kWh";
      peakDemand = "194.5 MW";
      avgDaily = "3,480 kWh";
      anomaliesDetected = "14";
    } else if (energy.activeAnalyticsPeriod == "90 Days") {
      totalConsumption = "321,950 kWh";
      peakDemand = "202.1 MW";
      avgDaily = "3,512 kWh";
      anomaliesDetected = "38";
    }

    // Prepare BarChart rods for 24-hour load distribution
    final List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < energy.readings.length; i++) {
      final reading = energy.readings[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: reading.actualLoad,
              color: AppTheme.primary.withValues(alpha: 0.7),
              width: 5,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DATE RANGE FILTER
            Row(
              children: ["7 Days", "30 Days", "90 Days"].map((period) {
                final isSelected = energy.activeAnalyticsPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ScaleOnPress(
                    onTap: () => energy.setAnalyticsPeriod(period),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      onSelected: (selected) {
                        energy.setAnalyticsPeriod(period);
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      checkmarkColor: Colors.black,
                      showCheckmark: false,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 2. CONSUMPTION OVERVIEW CARDS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildSummaryCard(
                  "Total Consumption",
                  totalConsumption,
                  Icons.electric_bolt_outlined,
                  AppTheme.primary,
                ),
                _buildSummaryCard(
                  "Peak Demand",
                  peakDemand,
                  Icons.trending_up,
                  const Color(0xFF89CFF0),
                ),
                _buildSummaryCard(
                  "Avg Daily",
                  avgDaily,
                  Icons.calendar_today_outlined,
                  AppTheme.warning,
                ),
                _buildSummaryCard(
                  "Anomalies",
                  anomaliesDetected,
                  Icons.gpp_maybe_outlined,
                  AppTheme.error,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. CONSUMPTION vs PREDICTION CHART
            Card(
              color: AppTheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Actual vs Forecasted Load",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    EnergyChart(
                      readings: energy.readings,
                      showPredictionLine: true,
                    ),
                    const SizedBox(height: 12),
                    // Legend Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: AppTheme.primary),
                            const SizedBox(width: 6),
                            const Text(
                              "Actual Load",
                              style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            Container(width: 12, height: 12, color: const Color(0xFF89CFF0)),
                            const SizedBox(width: 6),
                            const Text(
                              "Forecasted Load",
                              style: TextStyle(fontSize: 11, color: AppTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. HOURLY DISTRIBUTION BAR CHART
            Card(
              color: AppTheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hourly Load Distribution",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          minY: 0,
                          maxY: 220,
                          barGroups: barGroups,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppTheme.outlineVariant.withValues(alpha: 0.15),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 50,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}M',
                                    style: AppTheme.geistMonoStyle(fontSize: 9, color: AppTheme.onSurfaceVariant),
                                  );
                                },
                                reservedSize: 32,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 4,
                                getTitlesWidget: (value, meta) {
                                  final hr = value.toInt();
                                  if (hr >= 0 && hr < 24) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: Text(
                                        '${hr.toString().padLeft(2, '0')}:00',
                                        style: AppTheme.geistMonoStyle(fontSize: 9, color: AppTheme.onSurfaceVariant),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                                reservedSize: 24,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: AppTheme.surfaceContainerHighest,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${group.x.toString().padLeft(2, '0')}:00\n',
                                  const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                                  children: [
                                    TextSpan(
                                      text: '${rod.toY.toStringAsFixed(1)} MW',
                                      style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5. ANOMALY LOG TABLE
            Card(
              color: AppTheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detected Anomalies",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        horizontalMargin: 4,
                        columns: [
                          DataColumn(label: Text("Date", style: AppTheme.geistMonoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          DataColumn(label: Text("Time", style: AppTheme.geistMonoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          DataColumn(label: Text("Load (MW)", style: AppTheme.geistMonoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          DataColumn(label: Text("Deviation", style: AppTheme.geistMonoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                          DataColumn(label: Text("Status", style: AppTheme.geistMonoStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary))),
                        ],
                        rows: [
                          DataRow(cells: [
                            const DataCell(Text("2026-06-09", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("14:00", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("185.3", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("+35.5 MW", style: TextStyle(color: AppTheme.statusCritical, fontWeight: FontWeight.w600, fontSize: 12))),
                            const DataCell(StatusBadge(status: "Critical")),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text("2026-06-09", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("19:00", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("171.0", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("+18.0 MW", style: TextStyle(color: AppTheme.statusWarning, fontWeight: FontWeight.w600, fontSize: 12))),
                            const DataCell(StatusBadge(status: "Warning")),
                          ]),
                          DataRow(cells: [
                            const DataCell(Text("2026-06-09", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("08:00", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("104.2", style: TextStyle(fontSize: 12))),
                            const DataCell(Text("-12.0 MW", style: TextStyle(color: AppTheme.statusWarning, fontWeight: FontWeight.w600, fontSize: 12))),
                            const DataCell(StatusBadge(status: "Warning")),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
