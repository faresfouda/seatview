import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:seatview/Components/VIPRoomCard.dart';
import 'package:seatview/Main/RestaurantBookingScreen.dart';
import 'package:http/http.dart' as http;


class RestaurantAboutScreen extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final int initialTabIndex;

  const RestaurantAboutScreen({
    required this.restaurant,
    required this.initialTabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${restaurant['name']} '), // Correct key usage here
          bottom: TabBar(
            labelColor: Colors.red[600],
            indicatorColor: Colors.red[600],
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3.0,
            tabs: [
              Tab(text: restaurant['aboutTabTitle'] ?? 'About'),
              Tab(text: restaurant['galleryTabTitle'] ?? 'Gallery'),
              Tab(text: restaurant['tablesTabTitle'] ?? 'Tables'),
              Tab(text: restaurant['vipRoomsTabTitle'] ?? 'VIP Rooms'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AboutTab(restaurant: restaurant),
            GalleryTab(restaurant: restaurant),
            TablesLocationTab(restaurant: restaurant),
            VIPRoomsTab(restaurantId: restaurant['id'],),
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
              restaurant['profileImage'] ?? 'assets/placeholder.png',  // Using data from the restaurant object with fallback
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
            restaurant['title'] ?? 'Restaurant Name Not Available', // Fallback if title is not available
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            restaurant['description'] ?? 'Description not available.', // Fallback if description is not available
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
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    var galleryImages = restaurant['galleryImages'] ?? []; // Fallback to an empty list if not available
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: galleryImages.isEmpty
          ? const Center(child: Text("No images available"))
          : GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Adjust based on screen width
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              galleryImages[index],
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
              restaurant['layoutImage'] ?? 'assets/placeholder.png', // Use restaurant layout image with fallback
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




class VIPRoomsTab extends StatefulWidget {
  final String restaurantId;

  const VIPRoomsTab({required this.restaurantId});

  @override
  _VIPRoomsTabState createState() => _VIPRoomsTabState();
}

class _VIPRoomsTabState extends State<VIPRoomsTab> {
  List<dynamic> vipRooms = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchVIPRooms();
  }

  Future<void> fetchVIPRooms() async {
    final url = 'https://restaurant-reservation-sys.vercel.app/vip-rooms/restaurant/${widget.restaurantId}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print(response.body);
        final data = json.decode(response.body);
        setState(() {
          vipRooms = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          print(response.body);
          isLoading = false;
          errorMessage = 'Failed to load VIP rooms';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : vipRooms.isEmpty
        ? Center(child: Text(errorMessage.isEmpty ? 'No VIP rooms available' : errorMessage))
        : ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: vipRooms.length,
      itemBuilder: (context, index) {
        var room = vipRooms[index];
        return VIPRoomCard(room: room); // Using VIPRoomCard for each room
      },
    );
  }
}

