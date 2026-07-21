import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GaugeWidget extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String label;
  final String unit;
  final Color? color;

  const GaugeWidget({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 200.0,
    this.label = "LOAD",
    this.unit = "MW",
    this.color,
  });

  @override
  State<GaugeWidget> createState() => _GaugeWidgetState();
}

class _GaugeWidgetState extends State<GaugeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: widget.min, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: oldWidget.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? AppTheme.primary;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 110,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GaugePainter(
                    value: _animation.value,
                    min: widget.min,
                    max: widget.max,
                    color: activeColor,
                    trackColor: AppTheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _animation.value.toStringAsFixed(1),
                            style: AppTheme.geistMonoStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.unit,
                            style: AppTheme.geistMonoStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Text(
            widget.label.toUpperCase(),
            style: AppTheme.geistMonoStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final Color color;
  final Color trackColor;

  _GaugePainter({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 15);
    final radius = math.min(size.width / 2, size.height) - 10;
    
    const startAngle = 140.0 * math.pi / 180.0;
    const sweepAngle = 260.0 * math.pi / 180.0;

    // 1. Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // 2. Draw active arc
    final percentage = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final activeSweepAngle = sweepAngle * percentage;

    if (activeSweepAngle > 0) {
      final activePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      // Add a light shadow/glow behind active line if possible
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweepAngle,
        false,
        glowPaint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        activeSweepAngle,
        false,
        activePaint,
      );
    }

    // 3. Draw mini tick marks along the arc
    const tickCount = 9;
    final tickPaint = Paint()
      ..color = AppTheme.onSurfaceVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    for (int i = 0; i < tickCount; i++) {
      final angle = startAngle + (sweepAngle * (i / (tickCount - 1)));
      final cosVal = math.cos(angle);
      final sinVal = math.sin(angle);
      
      final innerPoint = Offset(
        center.dx + (radius - 12) * cosVal,
        center.dy + (radius - 12) * sinVal,
      );
      final outerPoint = Offset(
        center.dx + (radius - 6) * cosVal,
        center.dy + (radius - 6) * sinVal,
      );
      
      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
