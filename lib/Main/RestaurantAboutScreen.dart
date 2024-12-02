import 'package:flutter/material.dart';

class RestaurantAboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About the Restaurant'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://i.pinimg.com/736x/6b/08/3b/6b083bd6cfa02b3ca4cce07a018600c8.jpg', // Replace with actual image URL
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Restaurant Name
            const Text(
              'Delicious Bites Restaurant',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Restaurant Description
            const Text(
              'Welcome to Delicious Bites, where we serve the best cuisines in town. '
                  'Enjoy our wide variety of dishes prepared with the freshest ingredients in a cozy atmosphere.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Gallery Title
            const Text(
              'Gallery',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Gallery Section
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildGalleryImage(
                      'https://via.placeholder.com/150', context),
                  _buildGalleryImage(
                      'https://via.placeholder.com/150', context),
                  _buildGalleryImage(
                      'https://via.placeholder.com/150', context),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Book a Table Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the RestaurantBookingScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantBookingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Your app's theme color
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
                ),
                child: const Text(
                  'Book a Table',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryImage(String imageUrl, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          height: 120,
          width: 120,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class RestaurantBookingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Table'),
      ),
      body: const Center(
        child: Text('Restaurant Booking Page'),
      ),
    );
  }
}
