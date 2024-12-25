import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:seatview/Components/component.dart';
import 'package:seatview/Login/Login.dart';
import 'package:seatview/Main/MainScreen.dart';
import 'package:seatview/model/user.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
// Tracks verification status
  bool _isChecking = false; // Tracks if a check is in progress

  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true); // Show a loader while checking
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      // Get the current user's email (assuming you are storing it in the user session or context)
      final String email = user?.email ?? ''; // Default value if null
      // Replace this with actual user email logic

      // Make the API call to check email verification status
      final response = await http.get(
        Uri.parse('https://restaurant-reservation-sys.vercel.app/users/verify-status?email=$email'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success' && responseData['isConfirmed'] == true) {
          setState(() {
          });
          DefaultSnackbar.show(
            context,
            "Email verified successfully!",
            backgroundColor: Colors.green,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your home screen
                (route) => false,
          );
        } else {
          DefaultSnackbar.show(
            context,
            responseData['message'] ?? "Email not verified yet.",
            backgroundColor: Colors.orange,
          );
        }
      } else {
        DefaultSnackbar.show(
          context,
          "Failed to check email verification status.",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      DefaultSnackbar.show(
        context,
        "Error checking verification status: $e",
        backgroundColor: Colors.red,
      );
      print(e);
    } finally {
      setState(() => _isChecking = false); // Hide the loader
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/auth_backgound.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Verify Your Email",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Please check your email and verify your account. After verification, click the button below to proceed.",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    if (_isChecking) const CircularProgressIndicator(),
                    if (!_isChecking)
                      DefaultElevatedButton(
                        onPressed: _checkVerificationStatus,
                        label: "Check Verification Status",
                      ),
                    const SizedBox(height: 20),
                    DefaultTextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, 'login');
                      },
                      text: "Back to Login",
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
