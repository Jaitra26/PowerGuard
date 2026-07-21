import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/energy_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/energy_chart.dart';
import '../widgets/alert_tile.dart';
import '../widgets/scale_on_press.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial telemetry data from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final energy = context.read<EnergyProvider>();
      if (energy.readings.isEmpty) {
        energy.fetchReadings();
      }
      if (energy.alerts.isEmpty) {
        energy.fetchAlerts();
      }
    });
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceContainerHigh,
      highlightColor: AppTheme.surfaceContainerHighest,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
            children: List.generate(4, (_) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            )),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final energy = Provider.of<EnergyProvider>(context);
    final theme = Theme.of(context);

    final userName = auth.currentUser?.fullName ?? "Grid Operator";
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    // Compute dynamic status details
    String statusTitle;
    Color statusColor;
    IconData statusIcon;

    switch (energy.systemStatus) {
      case 'Critical':
        statusTitle = "SYSTEM CRITICAL";
        statusColor = AppTheme.statusCritical;
        statusIcon = Icons.error;
        break;
      case 'Warning':
        statusTitle = "SYSTEM WARNING";
        statusColor = AppTheme.statusWarning;
        statusIcon = Icons.warning;
        break;
      case 'Normal':
      default:
        statusTitle = "SYSTEM NORMAL";
        statusColor = AppTheme.statusNormal;
        statusIcon = Icons.check_circle;
    }

    // Metrics values derived from readings if loaded
    String currentLoad = "0.0 MW";
    String predictedLoad = "0.0 MW";
    String theftRisk = "Low";

    if (energy.readings.isNotEmpty) {
      final latest = energy.readings.last;
      currentLoad = "${latest.actualLoad} MW";
      predictedLoad = "${latest.predictedLoad} MW";
      theftRisk = latest.theftRisk;
    }

    // Show last 3 active alerts
    final recentAlerts = energy.alerts.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: AppTheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              "PowerGuard",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ScaleOnPress(
              onTap: () => context.go('/profile'),
              child: Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  radius: 18,
                  child: Text(
                    userName.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: energy.refreshAll,
        color: AppTheme.primary,
        backgroundColor: AppTheme.surfaceContainerHigh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. GREETING HEADER
              Text(
                "Good Morning, $userName",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // telemetries loader
              if (energy.isLoadingReadings || energy.isLoadingAlerts)
                _buildShimmer(context)
              else ...[
                // 2. LIVE STATUS BANNER
                Card(
                  color: AppTheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.1),
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 4,
                          color: statusColor,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                            child: Row(
                              children: [
                                Icon(statusIcon, color: statusColor, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        statusTitle,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        "All subsystems active & synchronized",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: energy.systemStatus),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. METRICS GRID (2 columns)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    MetricCard(
                      label: "Current Load",
                      value: currentLoad,
                      icon: Icons.electrical_services,
                      index: 0,
                    ),
                    MetricCard(
                      label: "Predicted Load",
                      value: predictedLoad,
                      icon: Icons.analytics_outlined,
                      index: 1,
                      accentColor: const Color(0xFF89CFF0),
                    ),
                    MetricCard(
                      label: "Daily Usage",
                      value: "3,412 kWh",
                      icon: Icons.bolt,
                      index: 2,
                    ),
                    MetricCard(
                      label: "Theft Risk",
                      value: theftRisk,
                      icon: Icons.security_outlined,
                      index: 3,
                      accentColor: theftRisk == "High"
                          ? AppTheme.statusCritical
                          : (theftRisk == "Medium"
                              ? AppTheme.statusWarning
                              : AppTheme.statusNormal),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. LOAD TREND CHART
                Card(
                  color: AppTheme.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Load Trend — Last 24 Hours",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        EnergyChart(
                          readings: energy.readings,
                          showPredictionLine: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 5. RECENT ALERTS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Alerts",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to alerts tab. GoRouter handles branches
                        // Since alerts is branch index 3, we can tap or navigate:
                        context.go('/alerts');
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (recentAlerts.isEmpty)
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: AppTheme.onSurfaceVariant),
                        SizedBox(height: 8),
                        Text(
                          "No active alerts reported",
                          style: TextStyle(color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = recentAlerts[index];
                      return AlertTile(
                        alert: alert,
                        index: index,
                        onResolve: () {
                          energy.resolveAlert(alert.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Alert ${alert.id} resolved."),
                              backgroundColor: AppTheme.success.withValues(alpha: 0.8),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
