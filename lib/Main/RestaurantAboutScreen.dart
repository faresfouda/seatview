import 'package:flutter/material.dart';
import 'package:seatview/Components/VIPRoomCard.dart';
import 'package:seatview/Main/RestaurantBookingScreen.dart';

class RestaurantAboutScreen extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final int initialTabIndex; // Added parameter to accept initial tab index

  // Constructor to accept restaurant data and initial tab index
  const RestaurantAboutScreen({
    required this.restaurant,
    required this.initialTabIndex,  // New parameter for initial tab index
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTabIndex,  // Set the initial index of the tab to the passed value
      child: Scaffold(
        appBar: AppBar(
          title: Text('${restaurant['title']} Details'),
          bottom: TabBar(
            labelColor: Colors.red[600],
            indicatorColor: Colors.red[600],
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3.0,
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
            GalleryTab(restaurant: restaurant),
            TablesLocationTab(restaurant: restaurant),
            VIPRoomsTab(restaurant: restaurant),
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
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/placeholder.png', fit: BoxFit.cover); // Fallback image
              },
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
                    builder: (context) => RestaurantBookingScreen(restaurant: restaurant),
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
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Adjust based on screen width
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
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
              },
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
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
              },
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
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: restaurant['vipRooms'].length,
      itemBuilder: (context, index) {
        var room = restaurant['vipRooms'][index];
        return VIPRoomCard(room: room); // Using VIPRoomCard for each room
      },
    );
  }
}

