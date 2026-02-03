import 'package:flutter/material.dart';

class BreathingCycle extends StatefulWidget {
  final Duration inhale;
  final Duration exhale;
  final Duration pause;
  final double size;

  const BreathingCycle({
    super.key,
    required this.inhale,
    required this.exhale,
    required this.pause,
    this.size = 220,
  });

  @override
  State<BreathingCycle> createState() => _BreathingCycleState();
}

class _BreathingCycleState extends State<BreathingCycle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant BreathingCycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inhale != widget.inhale ||
        oldWidget.exhale != widget.exhale ||
        oldWidget.pause != widget.pause) {
      _controller.dispose();
      _initAnimation();
    }
  }

  void _initAnimation() {
    final total = widget.inhale + widget.exhale + widget.pause;
    _controller = AnimationController(vsync: this, duration: total)..repeat();

    final inhaleWeight = widget.inhale.inMilliseconds.toDouble();
    final exhaleWeight = widget.exhale.inMilliseconds.toDouble();
    final pauseWeight = widget.pause.inMilliseconds.toDouble();

    final items = <TweenSequenceItem<double>>[
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.0).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: inhaleWeight,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.35).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: exhaleWeight,
      ),
    ];
    if (pauseWeight > 0) {
      items.add(TweenSequenceItem(
        tween: ConstantTween<double>(0.35),
        weight: pauseWeight,
      ));
    }

    _scale = TweenSequence<double>(items).animate(_controller);
  }

  String _cueFor(double progress) {
    final inhaleMs = widget.inhale.inMilliseconds.toDouble();
    final exhaleMs = widget.exhale.inMilliseconds.toDouble();
    final pauseMs = widget.pause.inMilliseconds.toDouble();
    final totalMs = inhaleMs + exhaleMs + pauseMs;
    if (totalMs <= 0) return 'Exhale';
    final elapsed = progress * totalMs;
    if (elapsed < inhaleMs) return 'Inhale';
    if (elapsed < inhaleMs + exhaleMs) return 'Exhale';
    return pauseMs > 0 ? 'Pause' : 'Exhale';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final orb = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colorScheme.primary.withOpacity(0.9),
            colorScheme.primary.withOpacity(0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.35),
            blurRadius: 28,
            spreadRadius: 6,
          ),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        final cue = _cueFor(_controller.value);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cue,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ],
        );
      },
      child: orb,
    );
  }
}
