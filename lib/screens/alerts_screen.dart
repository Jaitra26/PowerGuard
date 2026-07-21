import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/energy_provider.dart';
import '../widgets/alert_tile.dart';
import '../widgets/scale_on_press.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final energy = context.read<EnergyProvider>();
      if (energy.alerts.isEmpty) {
        energy.fetchAlerts();
      }
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    final energy = context.read<EnergyProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Alert Management Tools",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
              ),
              const SizedBox(height: 8),
              const Text(
                "Administrative actions for managing current substation warnings and critical flags.",
                style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              ScaleOnPress(
                onTap: () {
                  energy.clearAllAlerts();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("All alert logs cleared. Empty state active."),
                      backgroundColor: AppTheme.warning,
                    ),
                  );
                },
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.statusCritical,
                    side: const BorderSide(color: AppTheme.statusCritical, width: 1),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text("PURGE ALL LOGS"),
                  onPressed: () {
                    energy.clearAllAlerts();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 12),
              ScaleOnPress(
                onTap: () {
                  energy.fetchAlerts();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mock alert entries reloaded."),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                },
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.black),
                  label: const Text("RE-LOAD DEFAULT MOCK LOGS"),
                  onPressed: () {
                    energy.fetchAlerts();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final energy = Provider.of<EnergyProvider>(context);
    final theme = Theme.of(context);
    final filtered = energy.filteredAlerts;

    final filterPills = ["All", "Critical", "Warning", "Normal", "Resolved"];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Alerts",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: "Settings Menu",
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. FILTER CHIPS ROW (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: filterPills.map((filter) {
                final isSelected = energy.activeAlertFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ScaleOnPress(
                    onTap: () => energy.setAlertFilter(filter),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        energy.setAlertFilter(filter);
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.onSurfaceVariant,
                        fontSize: 12,
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
          ),
          
          // 2. ALERTS LIST OR EMPTY STATE
          Expanded(
            child: energy.isLoadingAlerts
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLow,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                size: 64,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No Alerts Found",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Telemetry diagnostic readings are nominal.",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ScaleOnPress(
                              onTap: () {
                                energy.fetchAlerts();
                              },
                              child: TextButton(
                                onPressed: () {
                                  energy.fetchAlerts();
                                },
                                child: const Text(
                                  "Reset Mock Warnings",
                                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final alert = filtered[index];
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
          ),
        ],
      ),
    );
  }
}
