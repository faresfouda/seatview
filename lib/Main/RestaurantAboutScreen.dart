import 'package:flutter/material.dart';
import 'package:seatview/Main/RestaurantBookingScreen.dart';
import 'package:seatview/API/restaurant_list.dart';

class RestaurantAboutScreen extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  // Constructor to accept restaurant data
  const RestaurantAboutScreen({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${restaurant['title']} Details'),
          bottom: TabBar(
            labelColor: Colors.red[600],
            indicatorColor: Colors.red[600],
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Gallery'),
              Tab(text: 'Tables'),
              Tab(text: 'VIP Rooms'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AboutTab(restaurant: restaurant),
            GalleryTab(restaurant: restaurant), // Pass restaurant to GalleryTab
            TablesLocationTab(restaurant: restaurant), // Pass restaurant to TablesLocationTab
            VIPRoomsTab(restaurant: restaurant), // Pass restaurant to VIPRoomsTab
          ],
        ),
      ),
    );
  }
}

// About Tab
class AboutTab extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  // Constructor accepting restaurant data
  const AboutTab({required this.restaurant});

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
              restaurant['imageUrl'],  // Using data from the restaurant object
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            restaurant['title'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            restaurant['description'],
            style: const TextStyle(fontSize: 16),
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
  final Map<String, dynamic> restaurant;

  const GalleryTab({required this.restaurant});

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
        itemCount: restaurant['galleryImages'].length, // Assuming 'galleryImages' is a list in the restaurant data
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              restaurant['galleryImages'][index], // Access gallery images
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
  final Map<String, dynamic> restaurant;

  const TablesLocationTab({required this.restaurant});

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
              restaurant['layoutImage'], // Use restaurant layout image
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
  final Map<String, dynamic> restaurant;

  const VIPRoomsTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: List.generate(restaurant['vipRooms'].length, (index) {
        var room = restaurant['vipRooms'][index]; // Access VIP room data
        return _buildVIPRoomCard(room['name'], room['imageUrl'], room['description']);
      }),
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
