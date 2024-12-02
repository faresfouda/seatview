import 'package:flutter/material.dart';
import 'package:seatview/Main/RestaurantBookingScreen.dart';

class RestaurantAboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant Details'),
          bottom:  TabBar(
            labelColor: Colors.red[600],
            indicatorColor: Colors.red[600],
            tabs: [
              Tab(text: 'About'),
              Tab(text: 'Vips'),
              Tab(text: 'Tables'),
              Tab(text: 'VIP Rooms'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // About Tab
            AboutTab(),

            // Gallery Tab
            GalleryTab(),

            // Tables Location Tab
            TablesLocationTab(),

            // VIP Rooms Tab
            VIPRoomsTab(),
          ],
        ),
      ),
    );
  }
}

// About Tab
class AboutTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://i.pinimg.com/736x/6b/08/3b/6b083bd6cfa02b3ca4cce07a018600c8.jpg',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Delicious Bites Restaurant',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to Delicious Bites, where we serve the best cuisines in town. '
                'Enjoy our wide variety of dishes prepared with the freshest ingredients in a cozy atmosphere.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantBookingScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Book a Table',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Gallery Tab
class GalleryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://via.placeholder.com/150',
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

// Tables Location Tab
class TablesLocationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Restaurant Layout',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://i.pinimg.com/736x/3d/5b/a8/3d5ba8dbfc44cb0289960774e742c38e.jpg', // Replace with actual layout image
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

// VIP Rooms Tab
class VIPRoomsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildVIPRoomCard(
          'VIP Room 1',
          'https://i.pinimg.com/736x/61/46/81/6146818ab5942e55707b075424c395a2.jpg',
          'Spacious and luxurious for private dining.',
        ),
        const SizedBox(height: 16),
        _buildVIPRoomCard(
          'VIP Room 2',
          'https://i.pinimg.com/736x/62/4d/5a/624d5a33250700c26855ec40ee44cf42.jpg',
          'Exclusive space with premium service.',
        ),
      ],
    );
  }

  Widget _buildVIPRoomCard(String title, String imageUrl, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
