import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status; // "Normal" | "Warning" | "Critical" | "Resolved"

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = status.toUpperCase();

    switch (status) {
      case 'Normal':
      case 'success':
      case 'Resolved':
        color = AppTheme.statusNormal;
        if (status == 'Resolved') label = 'RESOLVED';
        break;
      case 'Warning':
        color = AppTheme.statusWarning;
        break;
      case 'Critical':
      case 'error':
        color = AppTheme.statusCritical;
        break;
      default:
        color = AppTheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        label,
        style: AppTheme.geistMonoStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}
