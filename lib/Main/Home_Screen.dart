import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: () async
        {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false );
          },
            icon: Icon(Icons.logout)
        ),
      ],
      ),
    );
  }
}
