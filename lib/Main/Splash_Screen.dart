import 'package:flutter/material.dart';

class Splash_Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
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
              Spacer(),
              // "Get Started" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), backgroundColor: Colors.blue, // Full-width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ), // Button color
                  ),
                  onPressed: () {
                    // Navigate to the next page or perform another action
                  },
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // "Already a member?" sign-in text
              GestureDetector(
                onTap: () {
                  // Navigate to sign-in page
                },
                child: Text(
                  'Already a member? Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 40), // Add some bottom spacing
            ],
          ),
        ],
      ),
    );
  }
}