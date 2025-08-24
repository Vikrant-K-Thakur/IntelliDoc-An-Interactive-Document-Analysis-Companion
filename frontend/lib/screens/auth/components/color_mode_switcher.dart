import 'package:flutter/material.dart';
import 'package:docuverse/constants/color_modes.dart';

class ColorModeSwitcher extends StatelessWidget {
  final ColorMode currentMode;
  final ValueChanged<ColorMode> onModeChanged;
  
  const ColorModeSwitcher({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ColorMode>(
      icon: Icon(Icons.palette, color: Colors.white),
      onSelected: onModeChanged,
      itemBuilder: (context) => ColorMode.values.map((mode) {
        return PopupMenuItem<ColorMode>(
          value: mode,
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColorModes.primaryColors[mode],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(AppColorModes.modeNames[mode]!),
            ],
          ),
        );
      }).toList(),
    );
  }
}