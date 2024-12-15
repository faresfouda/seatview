import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/menu_provider.dart';
import 'package:seatview/Login/Cubit_auth.dart';
import 'package:seatview/Login/Email_verification.dart';
import 'package:seatview/Login/Forget_password.dart';
import 'package:seatview/Login/Login.dart';
import 'package:seatview/Login/Signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seatview/Main/DessertsScreen.dart';
import 'package:seatview/Main/DrinksScreen.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/Main/MainScreen.dart';
import 'package:seatview/Main/MealsScreen.dart';
import 'package:seatview/Main/ProfileScreen.dart';
import 'package:seatview/Main/RestaurantAboutScreen.dart';
import 'package:seatview/Main/RestaurantsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit()..checkCurrentUser(), // AuthCubit
        ),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SeatView',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
            ));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AuthAuthenticated) {
            return MainScreen(); // If user is authenticated, show home screen
          } else if (state is AuthError) {
            return const LoginScreen(); // If user is not authenticated, show login screen
          }
          return const LoginScreen(); // Default screen when authentication state is unknown
        },
      ),
      darkTheme: ThemeData.light(),
      routes: {
        'login': (context) => const LoginScreen(),
        'signup': (context) => const SignupScreen(),
        'forgot_password': (context) => const ForgotPasswordScreen(),
        'home': (context) => MainScreen(),
        'verification': (context) => const EmailVerificationScreen(),
        'RestaurantAboutScreen': (context) => RestaurantAboutScreen(
            restaurant: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
        'ProfileScreen': (context) => ProfileScreen(),
        'RestaurantsScreen': (context) => RestaurantsScreen(),
        'DrinksScreen': (context) => const DrinksScreen(),
        'MealsScreen': (context) => const Mealsscreen(),
        'DessertsScreen': (context) => const DessertsScreen(),
      },
    );
  }
}
