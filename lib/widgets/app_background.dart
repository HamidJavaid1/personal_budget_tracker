import 'dart:ui';

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  const Color(0xFF050814),
                  const Color(0xFF0D1730),
                  const Color(0xFF13213E),
                ]
              : <Color>[
                  const Color(0xFFD8E9FF),
                  const Color(0xFFEFF7FF),
                  const Color(0xFFF9FCFF),
                ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -72,
            right: -54,
            child: _GlowBlob(
              color: isDark
                  ? const Color(0xFF00E4FF).withValues(alpha: 0.16)
                  : const Color(0xFF2B6EF7).withValues(alpha: 0.14),
              size: 180,
            ),
          ),
          Positioned(
            bottom: -88,
            left: -64,
            child: _GlowBlob(
              color: isDark
                  ? const Color(0xFF7F5CFF).withValues(alpha: 0.14)
                  : const Color(0xFF00C2FF).withValues(alpha: 0.10),
              size: 210,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
