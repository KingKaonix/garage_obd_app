import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium tachometer-style gauge with segmented tick marks.
///
/// Layout (semicircle, bottom-half, arcs upward from approx 135° to 45°):
///   - Outer track ring (dim)
///   - Active segmented ticks (bright blue) up to current rpm
///   - Inactive segmented ticks (dim) beyond current rpm
///   - Major hash marks at 0, 2k, 4k, 6k, 8k
///   - Redline zone marker at 8k
///   - Glowing needle pointing to current value
///   - Center cap
///   - Labels under the arc
class RpmGauge extends StatelessWidget {
  final double rpm;
  final double maxRpm;

  /// Number of individual LED-style tick segments
  final int segmentCount;

  const RpmGauge({
    super.key,
    this.rpm = 0,
    this.maxRpm = 8000,
    this.segmentCount = 30,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 0.55;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // The painter draws: track, ticks, hash marks, needle, center cap
              Positioned.fill(
                child: CustomPaint(
                  painter: _GaugePainter(
                    rpm: rpm,
                    maxRpm: maxRpm,
                    segmentCount: segmentCount,
                  ),
                ),
              ),
              // RPM value
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.52,
                child: Text(
                  _formatRpm(rpm),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              // RPM unit label
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.45,
                child: Text(
                  'RPM × 1000',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.028,
                    color: const Color(0xFF667),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatRpm(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k'
          .replaceAll('.0k', ',000')
          .replaceAll('.', ',');
    }
    return value.toStringAsFixed(0);
  }
}

class _GaugePainter extends CustomPainter {
  final double rpm;
  final double maxRpm;
  final int segmentCount;

  _GaugePainter({
    required this.rpm,
    required this.maxRpm,
    required this.segmentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.43;
    const startAngle = math.pi * 1.35;  // ~243° → starts bottom-left
    const sweepAngle = math.pi * 1.3;   // ~234° → ends bottom-right

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ---------------------------------------------------------------
    // 1. Outer track (thin, dim)
    // ---------------------------------------------------------------
    paint
      ..color = const Color(0xFF2a2a3e)
      ..strokeWidth = radius * 0.08;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // ---------------------------------------------------------------
    // 2. Segmented tick marks (LED-style individual segments)
    // ---------------------------------------------------------------
    final tickStartRadius = radius * 0.82;
    final tickEndRadius = radius * 0.95;
    final segmentAngle = sweepAngle / (segmentCount + 1);
    final activeSegments = (rpm / maxRpm * segmentCount).round().clamp(0, segmentCount);

    for (int i = 1; i <= segmentCount; i++) {
      final angle = startAngle + segmentAngle * i;
      final isActive = i <= activeSegments;
      final isRedline = i > segmentCount * 0.85; // Last ~15% is red zone

      final tickXStart = center.dx + tickStartRadius * math.cos(angle);
      final tickYStart = center.dy + tickStartRadius * math.sin(angle);
      final tickXEnd = center.dx + tickEndRadius * math.cos(angle);
      final tickYEnd = center.dy + tickEndRadius * math.sin(angle);

      paint
        ..strokeWidth = radius * 0.04
        ..strokeCap = StrokeCap.round;

      if (isActive) {
        paint.color = isRedline
            ? const Color(0xFFf55)  // Red for redline zone
            : const Color(0xFF44aaff);  // Bright blue for active
      } else {
        paint.color = const Color(0xFF2a2a3e);  // Dim for inactive
      }

      canvas.drawLine(
        Offset(tickXStart, tickYStart),
        Offset(tickXEnd, tickYEnd),
        paint,
      );
    }

    // ---------------------------------------------------------------
    // 3. Major hash marks (longer lines at 0, 2k, 4k, 6k, 8k)
    // ---------------------------------------------------------------
    final hashPositions = [0.0, 0.25, 0.5, 0.75, 1.0];
    final hashStartRadius = radius * 0.72;
    final hashEndRadius = radius * 0.95;

    for (int i = 0; i < hashPositions.length; i++) {
      final t = hashPositions[i];
      final angle = startAngle + sweepAngle * t;
      final isMax = i == hashPositions.length - 1; // 8k RPM redline

      paint
        ..strokeWidth = radius * 0.05
        ..strokeCap = StrokeCap.round;

      if (isMax) {
        paint.color = const Color(0xFFf55);  // Red for redline
      } else {
        paint.color = const Color(0xFF556);  // Dim grey
      }

      final hashStart = Offset(
        center.dx + hashStartRadius * math.cos(angle),
        center.dy + hashStartRadius * math.sin(angle),
      );
      final hashEnd = Offset(
        center.dx + hashEndRadius * math.cos(angle),
        center.dy + hashEndRadius * math.sin(angle),
      );

      canvas.drawLine(hashStart, hashEnd, paint);
    }

    // ---------------------------------------------------------------
    // 4. Needle
    // ---------------------------------------------------------------
    final needleAngle = startAngle + sweepAngle * (rpm / maxRpm).clamp(0.0, 1.0);
    final needleLength = radius * 0.78;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // Needle glow (shadow)
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF44aaff).withValues(alpha: 0.4),
          const Color(0xFF44aaff).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromPoints(center, needleTip));

    glowPaint
      ..strokeWidth = radius * 0.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleTip, glowPaint);

    // Needle line
    final needlePaint = Paint()
      ..color = const Color(0xFF44aaff)
      ..strokeWidth = radius * 0.035
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(center, needleTip, needlePaint);

    // Needle tip dot
    canvas.drawCircle(
      needleTip,
      radius * 0.03,
      Paint()
        ..color = const Color(0xFF44aaff)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      needleTip,
      radius * 0.02,
      Paint()..color = const Color(0xFF44aaff),
    );

    // ---------------------------------------------------------------
    // 5. Center cap
    // ---------------------------------------------------------------
    final capRadius = radius * 0.06;
    canvas.drawCircle(
      center,
      capRadius,
      Paint()..color = const Color(0xFF1a1a28)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      capRadius,
      Paint()
        ..color = const Color(0xFF44aaff)
        ..strokeWidth = radius * 0.025
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.rpm != rpm || oldDelegate.maxRpm != maxRpm || oldDelegate.segmentCount != segmentCount;
  }
}
