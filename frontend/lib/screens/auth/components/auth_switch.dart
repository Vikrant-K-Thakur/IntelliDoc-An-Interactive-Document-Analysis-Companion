import 'package:flutter/material.dart';

class AuthSwitch extends StatelessWidget {
  final Color primaryColor;
  final String text;
  final String buttonText;
  final VoidCallback onPressed;
  
  const AuthSwitch({
    super.key,
    required this.primaryColor,
    required this.text,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}