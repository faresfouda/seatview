import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/auth_service.dart';
import 'package:seatview/Components/component.dart';
import 'package:seatview/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RestaurantOwnerSignupScreen extends StatefulWidget {
  const RestaurantOwnerSignupScreen({super.key});

  @override
  _RestaurantOwnerSignupScreenState createState() => _RestaurantOwnerSignupScreenState();
}

class _RestaurantOwnerSignupScreenState extends State<RestaurantOwnerSignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final fullName = _fullNameController.text.trim();
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        final confirmPassword = _confirmPasswordController.text.trim();
        final phone = _phoneController.text.trim();

        if (password != confirmPassword) {
          DefaultSnackbar.show(
            context,
            "Passwords do not match",
            backgroundColor: Colors.red,
          );
          return;
        }

        final authService = AuthService();
        final response = await authService.signUp(
          fullName: fullName,
          email: email,
          password: password,
          phone: phone,
          role: 'restaurantOwner'
        );

        print("SignUp Response: $response"); // Debugging log

        if (response['success']) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          final token = response['token'] ?? '';

          // Check if the token is empty
          if (token.isEmpty) {
            print("Error: Token is missing in the API response");
          }

          userProvider.setUserData(UserModel.fromJson(response['user']), token);

          // Save token persistently (if applicable)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          DefaultSnackbar.show(
            context,
            response['message'] ?? 'Sign-up successful!',
            backgroundColor: Colors.green,
          );

          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, 'verification');
        } else {
          DefaultSnackbar.show(
            context,
            response['message'] ?? 'An error occurred',
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        print("SignUp Error: $e"); // Debugging log
        DefaultSnackbar.show(
          context,
          'Sign-up failed: $e',
          backgroundColor: Colors.red,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
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
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: const Text(
                          "RESTAURANT OWNER SIGN UP",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      DefaultTextField(
                        controller: _fullNameController,
                        text: "Full Name",
                        obscure_value: false,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 20),
                      DefaultTextField(
                        controller: _emailController,
                        text: "Email",
                        obscure_value: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!_isEmailValid(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DefaultTextField(
                        controller: _passwordController,
                        text: "Password",
                        obscure_value: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      DefaultTextField(
                        controller: _confirmPasswordController,
                        text: "Confirm Password",
                        obscure_value: true,
                        validator: (value) =>
                        value != _passwordController.text.trim() ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 20),
                      DefaultTextField(
                        controller: _phoneController,
                        text: "Phone number",
                        obscure_value: false,
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your phone number' : null,
                      ),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : DefaultElevatedButton(
                        onPressed: _signUp,
                        label: "SIGN UP",
                      ),
                      DefaultTextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'login');
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
