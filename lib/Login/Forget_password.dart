import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seatview/Components/component.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        DefaultSnackbar.show(context,
            "Password reset email sent. Please check your inbox.",
            backgroundColor: Colors.green);
      } on FirebaseAuthException catch (e) {
        DefaultSnackbar.show(context, _getErrorMessage(e),
            backgroundColor: Colors.red);
      }
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allows screen to resize when keyboard opens
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/auth_backgound.jpg'), // Add your image here
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Forgot password form inside a scrollable box
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Form(
                  key: _formKey, // Assign the form key for validation
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "FORGOT PASSWORD",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      DefaultTextField(
                        controller: _emailController,
                        text: "Email",
                        obscure_value: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      DefaultElevatedButton(
                        onPressed: _resetPassword, // Call reset password function
                        label: 'SEND',
                      ),
                      const SizedBox(height: 20),
                      DefaultTextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'login');
                        },
                        text: "BACK TO LOGIN",
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
