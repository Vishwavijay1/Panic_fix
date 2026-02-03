import 'package:flutter/material.dart';

class BreathingOrb extends StatefulWidget {
  final Duration inhale;
  final Duration exhale;
  final Duration pause;
  final double size;

  const BreathingOrb({
    super.key,
    required this.inhale,
    required this.exhale,
    required this.pause,
    this.size = 220,
  });

  @override
  State<BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<BreathingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant BreathingOrb oldWidget) {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: child,
        );
      },
      child: Container(
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
      ),
    );
  }
}
