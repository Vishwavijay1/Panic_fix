import 'dart:math';

import 'package:flutter/material.dart';

class NightSky extends StatefulWidget {
  const NightSky({super.key});

  @override
  State<NightSky> createState() => _NightSkyState();
}

class _NightSkyState extends State<NightSky>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;
  late final List<_FallingStar> _fallingStars;

  @override
  void initState() {
    super.initState();
    final random = Random(42);
    _stars = List.generate(60, (_) => _Star.random(random));
    _fallingStars = List.generate(4, (_) => _FallingStar.random(random));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _NightSkyPainter(
                  stars: _stars,
                  fallingStars: _fallingStars,
                  progress: _controller.value,
                ),
                size: size,
              );
            },
          );
        },
      ),
    );
  }
}

class _NightSkyPainter extends CustomPainter {
  final List<_Star> stars;
  final List<_FallingStar> fallingStars;
  final double progress;

  _NightSkyPainter({
    required this.stars,
    required this.fallingStars,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final offset = Offset(star.x * size.width, star.y * size.height);
      starPaint.color = Colors.white.withOpacity(star.opacity);
      canvas.drawCircle(offset, star.radius, starPaint);
    }

    for (final star in fallingStars) {
      final localT = _progressFor(star.startTime, star.duration);
      if (localT == null) continue;

      final start = Offset(star.start.dx * size.width, star.start.dy * size.height);
      final end = Offset(star.end.dx * size.width, star.end.dy * size.height);
      final current = Offset.lerp(start, end, localT)!;
      final tail = Offset.lerp(start, end, (localT - 0.2).clamp(0.0, 1.0))!;

      final opacity = (1 - localT) * star.opacity;
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..strokeWidth = star.width
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(current, tail, paint);
    }
  }

  double? _progressFor(double start, double duration) {
    final t = progress;
    final delta = t - start;
    if (delta < 0) return null;
    if (delta > duration) return null;
    return delta / duration;
  }

  @override
  bool shouldRepaint(covariant _NightSkyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double opacity;

  _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });

  factory _Star.random(Random random) {
    return _Star(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: 0.6 + random.nextDouble() * 1.4,
      opacity: 0.2 + random.nextDouble() * 0.5,
    );
  }
}

class _FallingStar {
  final Offset start;
  final Offset end;
  final double startTime;
  final double duration;
  final double width;
  final double opacity;

  _FallingStar({
    required this.start,
    required this.end,
    required this.startTime,
    required this.duration,
    required this.width,
    required this.opacity,
  });

  factory _FallingStar.random(Random random) {
    final startX = 0.1 + random.nextDouble() * 0.7;
    final startY = random.nextDouble() * 0.4;
    final length = 0.15 + random.nextDouble() * 0.2;
    final dx = length * (0.6 + random.nextDouble() * 0.4);
    final dy = length * (0.6 + random.nextDouble() * 0.4);

    return _FallingStar(
      start: Offset(startX, startY),
      end: Offset(startX + dx, startY + dy),
      startTime: random.nextDouble() * 0.9,
      duration: 0.08 + random.nextDouble() * 0.06,
      width: 1.0 + random.nextDouble() * 1.2,
      opacity: 0.4 + random.nextDouble() * 0.4,
    );
  }
}
