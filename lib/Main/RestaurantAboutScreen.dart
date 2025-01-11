import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:seatview/Components/VIPRoomCard.dart';
import 'package:seatview/Main/RestaurantBookingScreen.dart';
import 'package:http/http.dart' as http;
import 'package:seatview/Components/theme.dart';  // Import your custom theme

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
          backgroundColor: Colors.white,
          title: Text('${restaurant['name']} ',style: TextStyle(color: Colors.black),),
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor, // Custom primary color from theme
            indicatorColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge!.color, // Using text color from theme
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
            VIPRoomsTab(restaurantId: restaurant['id']),
          ],
        ),
      ),
    );
  }
}

// About Tab
class AboutTab extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const AboutTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16), // Slightly more rounded corners
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Image.network(
                restaurant['profileImage'] ?? 'assets/placeholder.png',
                height: 250, // Increased height for better visibility
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/placeholder.png', fit: BoxFit.cover);
                },
              ),
            ),
          ),
          const SizedBox(height: 20), // More space around the image

          // Restaurant Title
          Text(
            restaurant['name'] ?? 'Restaurant Name Not Available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // Restaurant Description
          // Text(
          //   restaurant['description'] ?? 'Description not available.',
          //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //     fontSize: 16,
          //     color: Colors.black87,
          //   ),
          // ),
          const SizedBox(height: 24), // More space before details

          // Restaurant Details
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  restaurant['address'] ?? 'Address not available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.phone, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  restaurant['phone'] ?? 'Phone number not available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.access_time, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  restaurant['openingHours'] ?? 'Opening hours not available',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24), // More space before the button

          // Centered Action Button
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
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), // Larger padding
                elevation: 8, // Slightly higher elevation for more emphasis
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // More rounded corners
                shadowColor: Colors.black.withOpacity(0.3),
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
    var galleryImages = restaurant['galleryImages'] ?? [];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: galleryImages.isEmpty
          ? const Center(child: Text("No images available"))
          : GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
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
          Text(
            'Restaurant Layout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              restaurant['layoutImage'] ?? 'assets/placeholder.png',
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
        final data = json.decode(response.body);
        setState(() {
          vipRooms = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load VIP rooms';
        });
      }
    } catch (e) {
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
        return VIPRoomCard(room: room);
      },
    );
  }
}
