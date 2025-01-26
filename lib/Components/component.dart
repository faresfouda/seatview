import 'package:flutter/material.dart';


class DefaultTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const DefaultTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.color = Colors.white, // Default color is white
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}








class DefaultTextField extends StatelessWidget {
  final String text;
  final bool obscure_value;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const DefaultTextField({
    super.key,
    required this.text,
    required this.obscure_value,
    this.controller,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure_value,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white), // Text color
      decoration: InputDecoration(
        labelText: text,
        labelStyle: const TextStyle(color: Colors.white), // Label text color
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue), // Border color when not focused
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlueAccent), // Border color when focused
        ),
      ),
    );
  }
}









class DefaultElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final IconData? icon;
  final double iconSize;

  const DefaultElevatedButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon,
    this.iconSize = 24.0, // Default icon size
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.lightBlue, // Change this to your desired color
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize),
            const SizedBox(width: 8.0), // Space between icon and label
          ],
          if (label != null)
            Text(
              label!,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}



class DefaultSnackbar {
  static void show(BuildContext context, String message, {Color backgroundColor = Colors.black}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
