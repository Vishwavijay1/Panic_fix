import 'dart:async';

import 'package:flutter/material.dart';

class HoldToExitButton extends StatefulWidget {
  final VoidCallback onExit;
  final Duration holdDuration;

  const HoldToExitButton({
    super.key,
    required this.onExit,
    this.holdDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<HoldToExitButton> createState() => _HoldToExitButtonState();
}

class _HoldToExitButtonState extends State<HoldToExitButton> {
  Timer? _timer;
  bool _holding = false;

  void _startHold() {
    _timer?.cancel();
    setState(() => _holding = true);
    _timer = Timer(widget.holdDuration, () {
      widget.onExit();
    });
  }

  void _cancelHold() {
    _timer?.cancel();
    if (_holding) {
      setState(() => _holding = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: _holding
              ? scheme.primary.withOpacity(0.2)
              : scheme.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: scheme.primary.withOpacity(0.45),
            width: 1.2,
          ),
        ),
        child: Text(
          'Hold to exit',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
