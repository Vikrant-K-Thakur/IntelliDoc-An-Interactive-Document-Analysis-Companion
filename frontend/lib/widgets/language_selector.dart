import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String?> onChanged;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedLanguage,
      decoration: InputDecoration(
        labelText: 'Select Language',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      items: const [
        DropdownMenuItem(
          value: 'en',
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: 'hi',
          child: Text('Hindi'),
        ),
        DropdownMenuItem(
          value: 'mr',
          child: Text('Marathi'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}