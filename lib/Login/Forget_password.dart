import 'package:flutter/material.dart';
import 'package:seatview/API/auth_service.dart'; // Import your AuthService
import 'package:seatview/Components/component.dart'; // Import your custom components

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // State to show CircularProgressIndicator

  final AuthService _authService = AuthService(); // Instance of AuthService

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetPasswordRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading spinner
      });

      final email = _emailController.text.trim();

      try {
        // Call the forgot password API method
        final response = await _authService.forgotPassword(email: email);

        setState(() {
          _isLoading = false; // Hide loading spinner
        });

        // Check if the response is successful
        if (response['success']) {
          DefaultSnackbar.show(
            context,
            response['message'] ?? "Password reset email sent successfully",
            backgroundColor: Colors.green,
          );

          // Navigate back to the login screen
          Navigator.pop(context);
        } else {
          DefaultSnackbar.show(
            context,
            response['message'] ?? "Failed to send password reset email",
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide loading spinner in case of an error
        });

        // Handle errors gracefully
        print("Forgot password failed: $e");
        DefaultSnackbar.show(
          context,
          'An error occurred. Please try again later.',
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "FORGOT PASSWORD",
                        style: TextStyle(
                          fontSize: 30,
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
                      _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : DefaultElevatedButton(
                        onPressed: _sendResetPasswordRequest,
                        label: "SEND RESET LINK",
                      ),
                      DefaultTextButton(
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to the login screen
                        },
                        text: "BACK TO LOGIN",
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