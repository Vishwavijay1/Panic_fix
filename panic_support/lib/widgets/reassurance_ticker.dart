import 'dart:async';

import 'package:flutter/material.dart';

class ReassuranceTicker extends StatefulWidget {
  final List<String> lines;

  const ReassuranceTicker({super.key, required this.lines});

  @override
  State<ReassuranceTicker> createState() => _ReassuranceTickerState();
}

class _ReassuranceTickerState extends State<ReassuranceTicker> {
  late Timer _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 22), (_) {
      if (!mounted || widget.lines.isEmpty) return;
      setState(() {
        _index = (_index + 1) % widget.lines.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lines.isEmpty) return const SizedBox.shrink();
    final text = widget.lines[_index];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Text(
        text,
        key: ValueKey(text),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
            ),
      ),
    );
  }
}
