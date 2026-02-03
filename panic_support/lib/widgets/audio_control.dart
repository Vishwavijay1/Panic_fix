import 'dart:async';

import 'package:flutter/material.dart';

class AudioControl extends StatefulWidget {
  final bool enabled;
  final double volume;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolumeChanged;

  const AudioControl({
    super.key,
    required this.enabled,
    required this.volume,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  @override
  State<AudioControl> createState() => _AudioControlState();
}

class _AudioControlState extends State<AudioControl> {
  bool _hovering = false;
  bool _pinned = false;
  Timer? _hideTimer;

  void _showPinned() {
    _hideTimer?.cancel();
    setState(() => _pinned = true);
    _hideTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => _pinned = false);
      }
    });
  }

  void _hidePinned() {
    _hideTimer?.cancel();
    if (_pinned) {
      setState(() => _pinned = false);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _hovering || _pinned;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () {
              if (!widget.enabled) {
                widget.onToggle();
              }
              _showPinned();
            },
            icon: Icon(widget.enabled ? Icons.volume_up : Icons.volume_off),
            label: Text(widget.enabled ? 'Audio on' : 'Audio off'),
            style: TextButton.styleFrom(
              foregroundColor: scheme.primary,
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: visible
                ? Container(
                    key: const ValueKey('slider'),
                    width: 170,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: scheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            widget.enabled
                                ? Icons.volume_off
                                : Icons.volume_up,
                          ),
                          onPressed: () {
                            widget.onToggle();
                            if (widget.enabled) {
                              _hidePinned();
                            }
                          },
                        ),
                        Expanded(
                          child: Slider(
                            value: widget.volume.clamp(0.0, 1.0),
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            onChanged: (value) => widget.onVolumeChanged(value),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}
