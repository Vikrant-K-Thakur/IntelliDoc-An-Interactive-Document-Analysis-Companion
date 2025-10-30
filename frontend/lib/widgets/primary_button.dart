import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
<<<<<<< HEAD
  final Color? textColor;
=======
  final Color? textColor; // New parameter
>>>>>>> 17955a8 (Updated project)

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
<<<<<<< HEAD
    this.textColor,
=======
    this.textColor, // Added as optional parameter
>>>>>>> 17955a8 (Updated project)
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                text,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
<<<<<<< HEAD
                      color: textColor,
=======
                      color: textColor, // Apply textColor if provided
>>>>>>> 17955a8 (Updated project)
                    ),
              ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 17955a8 (Updated project)
