import 'package:flutter/material.dart';

class AudioToggle extends StatelessWidget {
  final bool enabled;
  final VoidCallback onToggle;

  const AudioToggle({
    super.key,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: onToggle,
      icon: Icon(enabled ? Icons.volume_up : Icons.volume_off),
      label: Text(enabled ? 'Audio on' : 'Audio off'),
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
