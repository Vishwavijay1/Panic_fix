import 'package:flutter/material.dart';

import 'night_sky.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  static const dayTop = Color(0xFFF7E9DA);
  static const dayBottom = Color(0xFFEAC8A5);
  static const nightTop = Color(0xFF0B1020);
  static const nightBottom = Color(0xFF121B2F);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? [nightTop, nightBottom] : [dayTop, dayBottom];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          if (isDark) const Positioned.fill(child: NightSky()),
          child,
        ],
      ),
    );
  }
}
