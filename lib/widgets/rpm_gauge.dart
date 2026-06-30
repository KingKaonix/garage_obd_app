import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium automotive tachometer with segmented LED-style hash marks.
///
/// Features:
/// - Semicircular arc (bottom-open) from ~135° to ~45°
/// - Glowing outer ring with colored active region
/// - Individual bright tick marks (hash marks) lighting up progressively
/// - Major labeled hash marks at each 1k RPM
/// - Redline zone at the top of the range
/// - Glowing needle with shadow
/// - Center cap with accent ring
class RpmGauge extends StatelessWidget {
  final double rpm;
  final double maxRpm;
  final int segmentCount;

  const RpmGauge({
    super.key,
    this.rpm = 0,
    this.maxRpm = 8000,
    this.segmentCount = 40,
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
              Positioned.fill(
                child: CustomPaint(
                  painter: _GaugePainter(
                    rpm: rpm,
                    maxRpm: maxRpm,
                    segmentCount: segmentCount,
                  ),
                ),
              ),
              // RPM digital readout
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.52,
                child: Text(
                  _formatRpm(rpm),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              // RPM label
              Positioned(
                left: 0,
                right: 0,
                bottom: height * 0.44,
                child: Text(
                  'RPM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.032,
                    color: const Color(0xFF889),
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
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
      final thousands = (value / 1000).toStringAsFixed(1);
      return thousands.replaceAll('.', ','); // e.g. "3,500" for 3500 rpm
    }
    return value.toStringAsFixed(0);
  }
}

class _GaugePainter extends CustomPainter {
  final double rpm;
  final double maxRpm;
  final int segmentCount;
  final int _majorTickCount = 8; // 0 through 8000 in 1k steps

  _GaugePainter({
    required this.rpm,
    required this.maxRpm,
    required this.segmentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.43;
    // Arc from ~225° to ~315° (sweeping clockwise = ~234°)
    const startAngle = math.pi * 1.20; // ~216°
    const sweepAngle = math.pi * 1.30; // ~234° (covers most of the semicircle)

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // ---------------------------------------------------------------
    // 1. Outer glow ring - subtle background
    // ---------------------------------------------------------------
    paint
      ..color = const Color(0xFF1a1a2e)
      ..strokeWidth = radius * 0.09;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.92),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // ---------------------------------------------------------------
    // 2. Individual hash marks (LED segments)
    // ---------------------------------------------------------------
    final tickStartRadius = radius * 0.84;
    final tickEndRadius = radius * 0.96;
    final segmentAngle = sweepAngle / segmentCount;
    final activeSegments = (rpm / maxRpm * segmentCount).round().clamp(
      0,
      segmentCount,
    );

    for (int i = 0; i < segmentCount; i++) {
      final angle = startAngle + segmentAngle * (i + 0.5);
      final isActive = i < activeSegments;
      final rpmAtSegment = (i / segmentCount) * maxRpm;
      final isRedline = rpmAtSegment >= maxRpm * 0.82;

      final tickXStart = center.dx + tickStartRadius * math.cos(angle);
      final tickYStart = center.dy + tickStartRadius * math.sin(angle);
      final tickXEnd = center.dx + tickEndRadius * math.cos(angle);
      final tickYEnd = center.dy + tickEndRadius * math.sin(angle);

      paint
        ..strokeWidth = radius * 0.035
        ..strokeCap = StrokeCap.round;

      if (isActive) {
        if (isRedline) {
          paint.color = const Color(0xFFf44);
        } else {
          paint.color = const Color(0xFF44aaff);
        }
      } else {
        paint.color = const Color(0xFF2a2a3e);
      }

      canvas.drawLine(
        Offset(tickXStart, tickYStart),
        Offset(tickXEnd, tickYEnd),
        paint,
      );
    }

    // ---------------------------------------------------------------
    // 3. Active arc track (glowing path behind the needle)
    // ---------------------------------------------------------------
    if (activeSegments > 0) {
      final activeAngle = startAngle + segmentAngle * activeSegments;
      final activeArcPaint = Paint()
        ..color = const Color(0xFF44aaff).withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.09
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.92),
        startAngle,
        activeAngle - startAngle,
        false,
        activeArcPaint,
      );
    }

    // ---------------------------------------------------------------
    // 4. Major hash marks (longer lines at 0, 1k, 2k, ... 8k)
    // ---------------------------------------------------------------
    final majorHashStartRadius = radius * 0.72;
    final majorHashEndRadius = radius * 0.96;

    for (int i = 0; i <= _majorTickCount; i++) {
      final t = i / _majorTickCount;
      final angle = startAngle + sweepAngle * t;
      final isRedlineMark = i >= (_majorTickCount * 0.82).round();

      // Major hash
      paint
        ..strokeWidth = radius * 0.05
        ..strokeCap = StrokeCap.round;

      if (isRedlineMark) {
        paint.color = const Color(0xFFf44);
      } else {
        paint.color = const Color(0xFF556);
      }

      final hashStart = Offset(
        center.dx + majorHashStartRadius * math.cos(angle),
        center.dy + majorHashStartRadius * math.sin(angle),
      );
      final hashEnd = Offset(
        center.dx + majorHashEndRadius * math.cos(angle),
        center.dy + majorHashEndRadius * math.sin(angle),
      );

      canvas.drawLine(hashStart, hashEnd, paint);

      // Label (rpm value in thousands)
      final labelRadius = radius * 0.66;
      final labelPos = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final label = '${i}';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isRedlineMark ? const Color(0xFFf44) : const Color(0xFF667),
            fontSize: radius * 0.09,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();

      // Position label centered on the arc at the label radius
      final offset = Offset(
        labelPos.dx - textPainter.width / 2,
        labelPos.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }

    // ---------------------------------------------------------------
    // 5. Needle
    // ---------------------------------------------------------------
    final needleAngle =
        startAngle + sweepAngle * (rpm / maxRpm).clamp(0.0, 1.0);
    final needleLength = radius * 0.78;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // Needle shadow/glow
    final glowPaint = Paint()
      ..color = const Color(0xFF44aaff).withValues(alpha: 0.25)
      ..strokeWidth = radius * 0.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleTip, glowPaint);

    // Needle body
    final needlePaint = Paint()
      ..color = const Color(0xFF44aaff)
      ..strokeWidth = radius * 0.030
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(center, needleTip, needlePaint);

    // Needle tip glow
    canvas.drawCircle(
      needleTip,
      radius * 0.035,
      Paint()
        ..color = const Color(0xFF44aaff).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      needleTip,
      radius * 0.015,
      Paint()..color = const Color(0xFF44aaff),
    );

    // ---------------------------------------------------------------
    // 6. Center cap
    // ---------------------------------------------------------------
    final capOuterRadius = radius * 0.07;
    final capInnerRadius = radius * 0.04;

    // Outer ring
    canvas.drawCircle(
      center,
      capOuterRadius,
      Paint()
        ..color = const Color(0xFF1a1a28)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      capOuterRadius,
      Paint()
        ..color = const Color(0xFF44aaff)
        ..strokeWidth = radius * 0.02
        ..style = PaintingStyle.stroke,
    );

    // Inner dot
    canvas.drawCircle(
      center,
      capInnerRadius,
      Paint()..color = const Color(0xFF44aaff),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.rpm != rpm ||
        oldDelegate.maxRpm != maxRpm ||
        oldDelegate.segmentCount != segmentCount;
  }
}
