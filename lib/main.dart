import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seatview/Components/menu_provider.dart';
import 'package:seatview/Login/Email_verification.dart';
import 'package:seatview/Login/Forget_password.dart';
import 'package:seatview/Login/Login.dart';
import 'package:seatview/Login/Signup.dart';
import 'package:seatview/Main/DessertsScreen.dart';
import 'package:seatview/Main/DrinksScreen.dart';
import 'package:seatview/Main/FavoritesProvider.dart';
import 'package:seatview/Main/MainScreen.dart';
import 'package:seatview/Main/MealsScreen.dart';
import 'package:seatview/Main/ProfileScreen.dart';
import 'package:seatview/Main/RestaurantAboutScreen.dart';
import 'package:seatview/Main/RestaurantsScreen.dart';
import 'package:seatview/model/user.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userProvider = UserProvider();

  // Wait for the session check to complete before starting the app
  await userProvider.checkUserSession();
  print("User logged in: ${userProvider.isLoggedIn}");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => userProvider),
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<UserProvider>(builder: (context, userProvider, child) {
        if (userProvider.isLoggedIn) {
          // Check if the user is confirmed
          if (userProvider.user?.isConfirmed == true) {
            return MainScreen();
          } else {
            return const EmailVerificationScreen();
          }
        } else {
          return const LoginScreen();
        }
      }),
      darkTheme: ThemeData.light(),
      routes: _appRoutes(),
    );
  }


  Map<String, WidgetBuilder> _appRoutes() {
    return {
      'login': (context) => const LoginScreen(),
      'signup': (context) => const SignupScreen(),
      'forgot_password': (context) => const ForgotPasswordScreen(),
      'home': (context) => MainScreen(),
      'verification': (context) => const EmailVerificationScreen(),
      'RestaurantAboutScreen': (context) => RestaurantAboutScreen(
        initialTabIndex: 0,
        restaurant: ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>,
      ),
      'ProfileScreen': (context) => ProfileScreen(),
      'RestaurantsScreen': (context) => RestaurantsScreen(),
      'DrinksScreen': (context) => const DrinksScreen(),
      'MealsScreen': (context) => const Mealsscreen(),
      'DessertsScreen': (context) => const DessertsScreen(),
    };
  }
}


