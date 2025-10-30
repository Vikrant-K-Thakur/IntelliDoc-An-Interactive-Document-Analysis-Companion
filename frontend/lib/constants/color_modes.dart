import 'package:flutter/material.dart';

enum ColorMode {
  skyBlue,
  sunsetOrange,
  forestGreen,
  purpleHaze,
  arcticWhite
}

class AppColorModes {
  static final Map<ColorMode, String> modeNames = {
    ColorMode.skyBlue: 'Sky Blue',
    ColorMode.sunsetOrange: 'Sunset',
    ColorMode.forestGreen: 'Forest',
    ColorMode.purpleHaze: 'Purple',
    ColorMode.arcticWhite: 'Arctic',
  };

  static final Map<ColorMode, Color> primaryColors = {
    ColorMode.skyBlue: const Color(0xFF2196F3),
    ColorMode.sunsetOrange: const Color(0xFFFF7043),
    ColorMode.forestGreen: const Color(0xFF388E3C),
    ColorMode.purpleHaze: const Color(0xFF6A1B9A),
    ColorMode.arcticWhite: const Color(0xFF1976D2),
  };

  static final Map<ColorMode, Color> secondaryColors = {
    ColorMode.skyBlue: const Color(0xFF64B5F6),
    ColorMode.sunsetOrange: const Color(0xFFFF8A65),
    ColorMode.forestGreen: const Color(0xFF66BB6A),
    ColorMode.purpleHaze: const Color(0xFF9C27B0),
    ColorMode.arcticWhite: const Color(0xFF42A5F5),
  };

  static final Map<ColorMode, Color> textColors = {
    ColorMode.skyBlue: Colors.black87,
    ColorMode.sunsetOrange: Colors.black87,
    ColorMode.forestGreen: Colors.black87,
    ColorMode.purpleHaze: Colors.white,
    ColorMode.arcticWhite: Colors.black87,
  };
}