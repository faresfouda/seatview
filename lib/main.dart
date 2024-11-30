import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seatview/Login/Email_verification.dart';
import 'package:seatview/Login/Forget_password.dart';
import 'package:seatview/Login/Login.dart';
import 'package:seatview/Login/Signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seatview/Main/Home_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('==============User is currently signed out!');
      } else {
        print('==============User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SeatView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Something went wrong!"));
          } else if (snapshot.hasData) {
            // User is logged in, check email verification
            final user = snapshot.data!;
            if (!user.emailVerified) {
              return EmailVerificationScreen(); // Navigate to verification screen
            }
            return Home_Screen(); // Navigate to home
          } else {
            return LoginScreen(); // Navigate to login
          }
        },
      ),
      darkTheme: ThemeData.light(),
      routes: {
        'login': (context) => LoginScreen(),
        'signup': (context) => SignupScreen(),
        'forgot_password': (context) => ForgotPasswordScreen(),
        'home': (context) => Home_Screen(),
        'verification': (context) => EmailVerificationScreen()
      },
    );
  }
}
