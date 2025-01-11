import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package

class AppTheme {
  // Define custom colors
  static const Color primaryColor = Color(0xFFEF4444); // #ef4444
  static const Color secondaryColor = Color(0xFFDC2626); // #dc2626

  // Border radius
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(12)); // 12px border radius

  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryColor, // Primary color
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor).copyWith(
        secondary: secondaryColor, // Secondary color
      ),
      scaffoldBackgroundColor: Colors.white, // Background color
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.epilogue(fontSize: 16), // Use Epilogue font
        bodyMedium: GoogleFonts.epilogue(fontSize: 14), // Use Epilogue font
        displayLarge: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.bold), // Use Epilogue font
        // Add more text styles as necessary
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor, // AppBar background
        titleTextStyle: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold), // Use Epilogue font
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius, // Apply border radius to buttons
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: borderRadius, // Apply border radius to text fields
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor).copyWith(
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: Colors.black, // Dark background color
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.epilogue(fontSize: 16, color: Colors.white), // Use Epilogue font
        bodyMedium: GoogleFonts.epilogue(fontSize: 14, color: Colors.white), // Use Epilogue font
        displayLarge: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), // Use Epilogue font
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor, // AppBar background
        titleTextStyle: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), // Use Epilogue font
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor, // Button color
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius, // Apply border radius to buttons
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: borderRadius, // Apply border radius to text fields
        ),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
      ),
    );
  }
}
