import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert_model.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';
import 'scale_on_press.dart';

class AlertTile extends StatefulWidget {
  final AlertModel alert;
  final int index;
  final VoidCallback? onResolve;

  const AlertTile({
    super.key,
    required this.alert,
    this.index = 0,
    this.onResolve,
  });

  @override
  State<AlertTile> createState() => _AlertTileState();
}

class _AlertTileState extends State<AlertTile> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeIn,
    );

    // Slide in based on list index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color severityColor;
    IconData iconData;

    switch (widget.alert.severity) {
      case 'Critical':
        severityColor = AppTheme.statusCritical;
        iconData = Icons.error_outline;
        break;
      case 'Warning':
        severityColor = AppTheme.statusWarning;
        iconData = Icons.warning_amber_outlined;
        break;
      case 'Normal':
      default:
        severityColor = AppTheme.statusNormal;
        iconData = Icons.check_circle_outline;
    }

    final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(widget.alert.timestamp);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.outlineVariant.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left severity border line
                  Container(
                    width: 5,
                    color: severityColor,
                  ),
                  
                  // Main Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Severity circular icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: severityColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData,
                                  color: severityColor,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Title and Status
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.alert.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.alert.description,
                                      maxLines: _isExpanded ? 10 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.onSurfaceVariant,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Badges
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  StatusBadge(status: widget.alert.severity),
                                  if (widget.alert.status == 'Resolved') ...[
                                    const SizedBox(height: 6),
                                    const StatusBadge(status: 'Resolved'),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Bottom row details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Timestamp
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 12, color: AppTheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedTime,
                                    style: AppTheme.geistMonoStyle(
                                      fontSize: 11,
                                      color: AppTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Location tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 10, color: AppTheme.primary),
                                    const SizedBox(width: 2),
                                    Text(
                                      widget.alert.location.split(',')[0],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          // Expandable details section
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: _isExpanded
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Divider(height: 24, color: AppTheme.outlineVariant),
                                      const Text(
                                        "ACTION REPORT REQUIREMENT",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        "An investigation must be launched immediately at the coordinates logged. Verify meter physical status and current feed draws.",
                                        style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                                      ),
                                      if (widget.alert.status == 'Active' && widget.onResolve != null) ...[
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ScaleOnPress(
                                            onTap: widget.onResolve,
                                            child: ElevatedButton.icon(
                                              onPressed: widget.onResolve,
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                backgroundColor: AppTheme.primary,
                                              ),
                                              icon: const Icon(Icons.check, size: 16, color: Colors.black),
                                              label: const Text(
                                                "RESOLVE",
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
