import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/API/auth_service.dart';
import 'package:seatview/Components/component.dart';
import 'package:seatview/Main/AddNewRestaurantScreen.dart';
import 'package:seatview/Main/MainScreen.dart';
import 'package:seatview/model/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final AuthService _authService = AuthService();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkSession(); // Check if user is already logged in
  }

  Future<void> _checkSession() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.checkUserSession();
  }


  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading spinner
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // Call the login API method
        final response = await _authService.login(
          email: email,
          password: password,
        );

        setState(() {
          _isLoading = false; // Hide loading spinner
        });

        // Check if the response is successful
        if (response['success']) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);

          if (response['user'] != null) {
            final user = UserModel.fromJson(response['user']);

            // Check if the account is confirmed
            if (!user.isConfirmed) {
              Navigator.pushNamed(context, 'verification');
              DefaultSnackbar.show(
                context,
                'Your account is not confirmed. Please verify your email.',
                backgroundColor: Colors.orange,
              );
              return; // Exit early if account is not confirmed
            }

            userProvider.setUserData(
              user,
              response['token'] ?? '', // Provide a fallback for null token
            );

            DefaultSnackbar.show(
              context,
              response['message'] ?? "Login successful",
              backgroundColor: Colors.green,
            );

            // Check if the user has added a restaurant
            if (user.role =='restaurantOwner') {
              if(user.restaurant == null){
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AddNewRestaurantScreen(),
                  ),
                );
              }else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>MainScreen(userRole: 'restaurantOwner',) ,
                  ),
                );
              }
              
              
            } else {
              // Navigate to the main screen if the restaurant is added
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MainScreen(userRole: user.role),
                ),
              );
            }

          } else {
            DefaultSnackbar.show(
              context,
              'User data is missing.',
              backgroundColor: Colors.red,
            );
          }
        } else {
          DefaultSnackbar.show(
            context,
            response['message'] ?? "Login failed",
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false; // Hide loading spinner in case of an error
        });

        // Handle errors gracefully
        print("Login failed: $e");
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
                        "LOGIN",
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
                      const SizedBox(height: 20),
                      DefaultTextField(
                        controller: _passwordController,
                        text: "Password",
                        obscure_value: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
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
                        onPressed: _login,
                        label: "LOGIN",
                      ),
                      DefaultTextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'signup');
                        },
                        text: "DON'T HAVE AN ACCOUNT?",
                      ),
                      DefaultTextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'forgot_password');
                        },
                        text: "FORGOT PASSWORD?",
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
