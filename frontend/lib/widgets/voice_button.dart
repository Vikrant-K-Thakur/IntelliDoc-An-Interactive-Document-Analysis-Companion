import 'package:flutter/material.dart';

class VoiceButton extends StatelessWidget {
  final String languageCode;
  final VoidCallback onPressed;

  const VoiceButton({
    super.key,
    required this.languageCode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.volume_up),
      tooltip: 'Listen in ${_getLanguageName(languageCode)}',
      onPressed: onPressed,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }
}