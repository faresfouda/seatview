import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const CustomElevatedButton({
    required this.onPressed,
    required this.buttonText,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: Center(
        child: Text(
          buttonText,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
      ),
    );
  }
}
