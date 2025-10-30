// lib/screens/auth/components/gradient_background.dart
import 'package:flutter/material.dart';
import 'package:docuverse/constants/color_modes.dart';

class GradientBackground extends StatelessWidget {
  final ColorMode colorMode;
  final Widget child;
  
  const GradientBackground({
    super.key,
    required this.colorMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradient(colorMode),
      ),
      child: child,
    );
  }

  LinearGradient _getGradient(ColorMode mode) {
    switch (mode) {
      case ColorMode.skyBlue:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
        );
      case ColorMode.sunsetOrange:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
        );
      case ColorMode.forestGreen:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
        );
      case ColorMode.purpleHaze:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)],
        );
      case ColorMode.arcticWhite:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, const Color(0xFFE3F2FD)],
        );
    }
  }
}