import 'package:flutter/material.dart';

class Splash_Screen extends StatelessWidget {
  const Splash_Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://i.pinimg.com/736x/09/e6/ed/09e6ed0653078f870697cb0128b3d207.jpg'),
                //image: AssetImage('assets/background.jpeg'),
                filterQuality: FilterQuality.high,
                fit: BoxFit.fill
                // Add your image asset here
              ),
            ),
          ),
          // Overlaying content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // "Get Started" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.blue, // Full-width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ), // Button color
                  ),
                  onPressed: () {
                    // Navigate to the next page or perform another action
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // "Already a member?" sign-in text
              GestureDetector(
                onTap: () {
                  // Navigate to sign-in page
                },
                child: const Text(
                  'Already a member? Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40), // Add some bottom spacing
            ],
          ),
        ],
      ),
    );
  }
}