import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seatview/Components/component.dart';
import 'package:seatview/Main/MainScreen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // ignore: unused_field
  bool _isVerified = false; // Tracks verification status
  bool _isChecking = false; // Tracks if a check is in progress

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      DefaultSnackbar.show(context, "Verification email sent.");
    } catch (e) {
      DefaultSnackbar.show(
        context,
        "Error sending verification email: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true); // Show a loader while checking
    try {
      // Reload the user state
      await FirebaseAuth.instance.currentUser?.reload();

      // Get the updated user
      final updatedUser = FirebaseAuth.instance.currentUser;

      if (updatedUser != null && updatedUser.emailVerified) {
        setState(() => _isVerified = true);
        DefaultSnackbar.show(
          context,
          "Email verified successfully!",
          backgroundColor: Colors.green,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()), // Replace with your home screen
              (route) => false,
        );
      } else {
        DefaultSnackbar.show(context, "Email not verified yet. Please try again.");
      }
    } catch (e) {
      DefaultSnackbar.show(
        context,
        "Error checking verification status: $e",
        backgroundColor: Colors.red,
      );
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
                    DefaultElevatedButton(
                      onPressed: _sendVerificationEmail,
                      label: "Resend Verification Email",
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
