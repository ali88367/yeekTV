import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom Painter for Circular Progress Animation
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 3) / 2;

    // Smooth fill and unfill animation
    // First half (0.0 to 0.5): Fill clockwise from 0% to 100% (starts from top)
    // Second half (0.5 to 1.0): Unfill counter-clockwise from 100% to 0% (starts from top, goes backward)
    double sweepAngle;
    double startAngle = -math.pi / 2; // Start from top (12 o'clock)

    if (progress <= 0.5) {
      // Fill phase: 0% to 50% of animation = 0% to 100% of circle (clockwise)
      sweepAngle = (progress / 0.5) * 2 * math.pi;
    } else {
      // Unfill phase: 50% to 100% of animation = 100% to 0% of circle (counter-clockwise)
      // Use negative sweep angle to go counter-clockwise from top
      sweepAngle = -((1.0 - progress) / 0.5) * 2 * math.pi;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Expanding Ring Painter for Sign Logo Animation
class ExpandingRingPainter extends CustomPainter {
  final double progress;
  final double offset;

  ExpandingRingPainter({required this.progress, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale and opacity based on animation progress
    double scale;
    double opacity;

    // Match CSS keyframes exactly
    if (progress <= 0.15) {
      // 0% - 15%: scale(0.05) to scale(0.3), opacity 1
      scale = 0.05 + (progress / 0.15) * (0.3 - 0.05);
      opacity = 1.0;
    } else if (progress <= 0.40) {
      // 15% - 40%: scale(0.3) to scale(0.7), opacity 1
      scale = 0.3 + ((progress - 0.15) / 0.25) * (0.7 - 0.3);
      opacity = 1.0;
    } else if (progress <= 0.60) {
      // 40% - 60%: scale(0.7) to scale(1.0), opacity 0.85
      scale = 0.7 + ((progress - 0.40) / 0.20) * (1.0 - 0.7);
      opacity = 0.85;
    } else if (progress <= 0.75) {
      // 60% - 75%: scale(1.0) to scale(1.2), opacity 0.5
      scale = 1.0 + ((progress - 0.60) / 0.15) * (1.2 - 1.0);
      opacity = 0.5;
    } else if (progress <= 0.90) {
      // 75% - 90%: scale(1.2) to scale(1.35), opacity 0.2
      scale = 1.2 + ((progress - 0.75) / 0.15) * (1.35 - 1.2);
      opacity = 0.2;
    } else {
      // 90% - 100%: scale(1.35) to scale(1.45), opacity 0
      scale = 1.35 + ((progress - 0.90) / 0.10) * (1.45 - 1.35);
      opacity = 0.0;
    }

    // Create paint for ring
    final paint = Paint()
      ..color = const Color(0xFFEFBF04).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Calculate center with offset
    final center = Offset(size.width / 2, size.height / 2 + offset);

    // Calculate radius (scaled)
    final radius = (size.width / 2) * scale;

    // Draw the expanding ring
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(ExpandingRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.offset != offset;
  }
}

/// Particle Painter for Subscribe Button Animation
class ParticlePainter extends CustomPainter {
  final double progress;
  final double buttonWidth;
  final double buttonHeight;

  ParticlePainter({
    required this.progress,
    required this.buttonWidth,
    required this.buttonHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final maxDistance =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;

    // Create more particles with pink shades (50 particles total)
    final pinkShades = [
      const Color(0xFFFF69B4), // Hot pink
      const Color(0xFFFF1493), // Deep pink
      const Color(0xFFFFB6C1), // Light pink
      const Color(0xFFFFC0CB), // Pink
      const Color(0xFFFF91A4), // Salmon pink
      const Color(0xFFFF6B9D), // Rose pink
    ];

    // Main particles - spread throughout entire button including all sides (100 particles)
    for (int i = 0; i < 100; i++) {
      // Distribute particles evenly across the entire button area
      // Not just from center, but from all positions
      final normalizedIndex = i / 100.0;

      // Create particles from different starting points across the button
      final startX = (normalizedIndex * 3) % 1.0; // Distribute across width
      final startY = (normalizedIndex * 2.5) % 1.0; // Distribute across height

      // Angle varies for each particle
      final angle =
          (i * 0.618) * 2 * math.pi +
          (progress * 0.8); // Golden ratio for better distribution

      // Distance from starting point - particles move outward
      final distance = progress * maxDistance * (0.5 + (normalizedIndex * 0.8));

      // Particle position - spread from various points, not just center
      final baseX = startX * size.width;
      final baseY = startY * size.height;
      final x = baseX + math.cos(angle) * distance;
      final y = baseY + math.sin(angle) * distance;

      // Only draw if within button bounds
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        // Particle size varies (1.5-4 pixels)
        final particleSize = (1.5 + (i % 6) * 0.4) * (1 - progress * 0.3);

        // Opacity fades out
        final opacity = (1 - progress * 1.1).clamp(0.0, 1.0);

        final paint = Paint()
          ..color = pinkShades[i % pinkShades.length].withOpacity(opacity)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), particleSize, paint);
      }
    }

    // Additional particles from edges and corners (80 more particles)
    for (int i = 0; i < 80; i++) {
      // Start from edges and corners
      final edgeIndex = i % 4; // 4 edges

      double startX, startY;
      if (edgeIndex == 0) {
        // Top edge
        startX = (i / 80.0) * size.width;
        startY = 0;
      } else if (edgeIndex == 1) {
        // Right edge
        startX = size.width;
        startY = (i / 80.0) * size.height;
      } else if (edgeIndex == 2) {
        // Bottom edge
        startX = (1 - i / 80.0) * size.width;
        startY = size.height;
      } else {
        // Left edge
        startX = 0;
        startY = (1 - i / 80.0) * size.height;
      }

      final angle = (i * 0.5) * 2 * math.pi + (progress * 0.6);
      final distance = progress * maxDistance * 0.7;

      final x = startX + math.cos(angle) * distance;
      final y = startY + math.sin(angle) * distance;

      if (x >= 0 &&
          x <= size.width &&
          y >= 0 &&
          y <= size.height &&
          progress < 0.9) {
        final sparkleSize = (1.2 + (i % 4) * 0.3) * (1 - progress);
        final opacity = (1 - progress * 1.4).clamp(0.0, 1.0);

        final sparklePaint = Paint()
          ..color = pinkShades[(i + 2) % pinkShades.length].withOpacity(
            opacity * 0.85,
          )
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), sparkleSize, sparklePaint);
      }
    }

    // Corner particles - extra density at corners (50 more particles)
    for (int i = 0; i < 50; i++) {
      final corner = i % 4;
      double cornerX, cornerY;

      if (corner == 0) {
        cornerX = 0;
        cornerY = 0; // Top-left
      } else if (corner == 1) {
        cornerX = size.width;
        cornerY = 0; // Top-right
      } else if (corner == 2) {
        cornerX = size.width;
        cornerY = size.height; // Bottom-right
      } else {
        cornerX = 0;
        cornerY = size.height; // Bottom-left
      }

      final angle = (i * 0.4) * 2 * math.pi + (progress * 0.5);
      final distance = progress * maxDistance * 0.6;

      final x = cornerX + math.cos(angle) * distance;
      final y = cornerY + math.sin(angle) * distance;

      if (x >= 0 &&
          x <= size.width &&
          y >= 0 &&
          y <= size.height &&
          progress < 0.75) {
        final tinySize = (1.0 + (i % 3) * 0.3) * (1 - progress);
        final opacity = (1 - progress * 1.8).clamp(0.0, 1.0);

        final tinyPaint = Paint()
          ..color = pinkShades[(i + 4) % pinkShades.length].withOpacity(
            opacity * 0.7,
          )
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), tinySize, tinyPaint);
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
